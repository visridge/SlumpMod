// SlumpMod ranked LTS backend (ported from MustMod). Called by XangModRanked.uc on LTS game servers as
//   POST /functions/v1/ranked/<action>   header x-server-token, JSON body, JSON reply
//
// Actions: ping, connect, matchmake, result, abandon, cancel. Matchmaking and every Elo
// change happen here, never on the game server, so a modified server cannot rate itself.
//
// Servers authenticate with the RANKED_SERVER_TOKENS secret, a comma-separated list of
// name:token pairs; the name is what gets recorded on each match:
//   supabase secrets set RANKED_SERVER_TOKENS=eu-1:<long random>,eu-2:<long random>

import { createClient } from "jsr:@supabase/supabase-js@2";
import {
  average,
  balance,
  expectedScore,
  eloDelta,
  HIGH_ELO,
  isElite,
  isRestricted,
  LEAVE_PENALTY,
  LOW_ELO,
  pickLargestMatch,
  START_ELO,
  type Player,
  PROVEN_GAMES,
} from "./matchmaking.ts";

// ---- Setup -------------------------------------------------------------------------------

const serverByToken = new Map<string, string>();
for (const entry of (Deno.env.get("RANKED_SERVER_TOKENS") ?? "").split(",")) {
  const i = entry.indexOf(":");
  if (i > 0) serverByToken.set(entry.slice(i + 1).trim(), entry.slice(0, i).trim());
}

const db = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  { auth: { persistSession: false } },
);

type MatchPlayer = { steam_id: string; team: 1 | 2; elo_before: number };

class HttpError extends Error {
  constructor(public status: number, message: string) {
    super(message);
  }
}

function reply(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

function must<T>(result: { data: T | null; error: { message: string } | null }): T {
  if (result.error) throw new Error(result.error.message);
  return result.data as T;
}

const STEAM_ID = /^\d{1,20}$/;
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

function steamIds(value: unknown): string[] {
  if (!Array.isArray(value)) return [];
  return value.map(String).filter((id) => STEAM_ID.test(id));
}

function matchIdOf(body: Record<string, unknown>): string {
  const id = String(body.matchId ?? "");
  if (!UUID.test(id)) throw new HttpError(400, "bad_match_id");
  return id;
}

// ---- Players -----------------------------------------------------------------------------

/** Create unseen players at START_ELO, refresh names of known ones, return all of them. */
async function upsertPlayers(list: { steamId: string; name: string }[]): Promise<Player[]> {
  const now = new Date().toISOString();
  return must(
    await db
      .from("ranked_players")
      .upsert(
        list.map((p) => ({ steam_id: p.steamId, name: p.name.slice(0, 64), updated_at: now })),
        { onConflict: "steam_id" },
      )
      .select(),
  ) as Player[];
}

async function loadPlayers(ids: string[]): Promise<Map<string, Player>> {
  const rows = must(await db.from("ranked_players").select().in("steam_id", ids)) as Player[];
  return new Map(rows.map((p) => [p.steam_id, p]));
}

const describe = (p: Player) => ({ steamId: p.steam_id, name: p.name, elo: p.elo, games: p.games });

async function matchmake(server: string, body: Record<string, unknown>) {
  // Match size follows the queue: the server sends its limits, not a fixed size.
  const minTeamSize = Number(body.minTeamSize);
  const maxTeamSize = Number(body.maxTeamSize);
  if (
    !Number.isInteger(minTeamSize) || !Number.isInteger(maxTeamSize) ||
    minTeamSize < 1 || maxTeamSize > 16 || minTeamSize > maxTeamSize
  ) {
    throw new HttpError(400, "bad_team_size");
  }

  const seen = new Set<string>();
  const queued = (Array.isArray(body.players) ? body.players : [])
    .map((p) => ({ steamId: String(p?.steamId ?? ""), name: String(p?.name ?? "") }))
    .filter((p) => STEAM_ID.test(p.steamId) && !seen.has(p.steamId) && seen.add(p.steamId));

  if (queued.length < minTeamSize * 2) {
    return { ok: false, error: `need ${minTeamSize * 2} players, have ${queued.length}` };
  }

  // Keep the server's queue order: the upsert returns rows in no particular order.
  const byId = new Map((await upsertPlayers(queued)).map((p) => [p.steam_id, p]));
  const queue = queued.map((q) => byId.get(q.steamId)!);

  const picked = pickLargestMatch(queue, minTeamSize, maxTeamSize);
  if (!picked) return { ok: false, error: "not enough players within the allowed skill range" };
  const teamSize = picked.length / 2;

  const [team1, team2] = balance(picked);
  const team1Avg = average(team1);
  const team2Avg = average(team2);
  const total = (team: Player[]) => team.reduce((sum, p) => sum + p.elo, 0);

  const match = must(
    await db
      .from("ranked_matches")
      .insert({
        server,
        map: String(body.map ?? ""),
        team_size: teamSize,
        team1_avg: team1Avg,
        team2_avg: team2Avg,
        team1_total: total(team1),
        team2_total: total(team2),
        team1_win_chance: expectedScore(team1Avg, team2Avg),
      })
      .select("id")
      .single(),
  ) as { id: string };

  must(
    await db.from("ranked_match_players").insert([
      ...team1.map((p) => ({ match_id: match.id, steam_id: p.steam_id, team: 1, elo_before: p.elo })),
      ...team2.map((p) => ({ match_id: match.id, steam_id: p.steam_id, team: 2, elo_before: p.elo })),
    ]),
  );

  // Tell the players benched by the skill-gap rule why; plain overflow needs no reason.
  const pickedIds = new Set(picked.map((p) => p.steam_id));
  const matchHasElite = picked.some(isElite);
  const matchHasRestricted = picked.some(isRestricted);
  const excluded = queue
    .filter((p) => !pickedIds.has(p.steam_id))
    .flatMap((p) => {
      if (isRestricted(p) && matchHasElite) {
        return [{ steamId: p.steam_id, reason: `this match has players above ${HIGH_ELO} Elo, and after ${PROVEN_GAMES} games you need ${LOW_ELO}+ to be matched with them.` }];
      }
      if (isElite(p) && matchHasRestricted) {
        return [{ steamId: p.steam_id, reason: `you are above ${HIGH_ELO} Elo and this match has players below ${LOW_ELO}.` }];
      }
      return [];
    });

  return {
    ok: true,
    matchId: match.id,
    team1: team1.map(describe),
    team2: team2.map(describe),
    teamSize,
    team1Avg,
    team2Avg,
    excluded,
  };
}

// ---- Finishing matches -------------------------------------------------------------------

/**
 * Move an in-progress match to its final status. Only one call can ever win this, which is
 * what makes a retried result (or a result racing an abandon) harmless.
 */
async function claimMatch(server: string, matchId: string, update: Record<string, unknown>) {
  const rows = must(
    await db
      .from("ranked_matches")
      .update({ ...update, finished_at: new Date().toISOString() })
      .eq("id", matchId)
      .eq("server", server)
      .eq("status", "in_progress")
      .select("*"),
  ) as MatchRow[];
  if (rows.length === 0) throw new HttpError(409, "match_not_in_progress");

  const lineup = must(
    await db.from("ranked_match_players").select("steam_id, team, elo_before").eq("match_id", matchId),
  ) as MatchPlayer[];
  return { match: rows[0], lineup, players: await loadPlayers(lineup.map((m) => m.steam_id)) };
}

type Outcome = "win" | "loss" | "draw" | "left" | "void";

type MatchRow = {
  id: string;
  server: string;
  map: string;
  team_size: number;
  team1_avg: number;
  team2_avg: number;
  team1_win_chance: number;
  team1_score: number | null;
  team2_score: number | null;
  winner: number | null;
  status: string;
  finished_at: string | null;
};

type Change = { steamId: string; name: string; before: number; after: number; result: Outcome };

async function applyOutcome(
  matchId: string,
  player: Player,
  outcome: Outcome,
  eloAfter: number,
  stats: unknown,
) {
  const counter = { win: "wins", loss: "losses", draw: "draws", left: "leaves" } as const;
  if (outcome !== "void") {
    const key = counter[outcome];
    must(
      await db
        .from("ranked_players")
        .update({ elo: eloAfter, games: player.games + 1, [key]: player[key] + 1, updated_at: new Date().toISOString() })
        .eq("steam_id", player.steam_id),
    );
  }
  must(
    await db
      .from("ranked_match_players")
      .update({ elo_after: eloAfter, result: outcome, stats: stats ?? null })
      .eq("match_id", matchId)
      .eq("steam_id", player.steam_id),
  );
  return { steamId: player.steam_id, name: player.name, before: player.elo, after: eloAfter, result: outcome };
}

const penalised = (p: Player) => Math.max(0, p.elo - LEAVE_PENALTY);

async function result(server: string, body: Record<string, unknown>) {
  const matchId = matchIdOf(body);
  const winner = Number(body.winner);
  if (![0, 1, 2].includes(winner)) throw new HttpError(400, "bad_winner");

  const leavers = new Set(steamIds(body.leavers));
  const stats = statsByPlayer(body);

  // Rounds won; optional, so a missing or junk value is stored as unknown rather than rejected.
  const roundScore = (v: unknown) => (Number.isInteger(v) && (v as number) >= 0 ? v : null);

  const { match, lineup, players } = await claimMatch(server, matchId, {
    status: "completed",
    winner,
    team1_score: roundScore(body.team1Score),
    team2_score: roundScore(body.team2Score),
  });

  // Team strength from the Elo everyone had when the match was made.
  const avg = (team: number) => {
    const elos = lineup.filter((m) => m.team === team).map((m) => m.elo_before);
    return elos.reduce((a, b) => a + b, 0) / elos.length;
  };
  const expected1 = expectedScore(avg(1), avg(2));

  const changes: Change[] = [];
  for (const m of lineup) {
    const player = players.get(m.steam_id);
    if (!player) continue;

    if (leavers.has(m.steam_id)) {
      changes.push(await applyOutcome(matchId, player, "left", penalised(player), stats.get(m.steam_id)));
      continue;
    }

    const score = winner === 0 ? 0.5 : winner === m.team ? 1 : 0;
    const expected = m.team === 1 ? expected1 : 1 - expected1;
    const after = Math.max(0, player.elo + eloDelta(player.games, score, expected));
    const outcome: Outcome = winner === 0 ? "draw" : score === 1 ? "win" : "loss";
    changes.push(await applyOutcome(matchId, player, outcome, after, stats.get(m.steam_id)));
  }

  inBackground(() => postMatchResult(match, lineup, changes, stats));
  inBackground(updateLeaderboard);
  return { ok: true, changes };
}

/** The players[] stats array as steamId -> stats object. Leavers' come from a disconnect snapshot. */
function statsByPlayer(body: Record<string, unknown>): Map<string, unknown> {
  const stats = new Map<string, unknown>();
  for (const p of Array.isArray(body.players) ? body.players : []) {
    if (STEAM_ID.test(String(p?.steamId))) stats.set(String(p.steamId), p);
  }
  return stats;
}

/** Leavers lose LEAVE_PENALTY; the match is void for everyone else. Stats are kept either way. */
async function abandon(server: string, body: Record<string, unknown>) {
  const matchId = matchIdOf(body);
  const leavers = new Set(steamIds(body.leavers));
  const stats = statsByPlayer(body);
  const { match, lineup, players } = await claimMatch(server, matchId, { status: "abandoned" });

  const changes: Change[] = [];
  for (const m of lineup) {
    const player = players.get(m.steam_id);
    if (!player) continue;
    changes.push(
      leavers.has(m.steam_id)
        ? await applyOutcome(matchId, player, "left", penalised(player), stats.get(m.steam_id))
        : await applyOutcome(matchId, player, "void", player.elo, stats.get(m.steam_id)),
    );
  }

  inBackground(() => postAbandoned(match, changes, stats));
  inBackground(updateLeaderboard);
  return { ok: true, changes };
}

/** Admin cancel: void for everyone. */
async function cancel(server: string, body: Record<string, unknown>) {
  const matchId = matchIdOf(body);
  const { lineup, players } = await claimMatch(server, matchId, { status: "cancelled" });
  for (const m of lineup) {
    const player = players.get(m.steam_id);
    if (player) await applyOutcome(matchId, player, "void", player.elo, null);
  }
  return { ok: true };
}

/**
 * Elo for the name tag when a player joins an LTS map. Read-only: players are only stored
 * once matchmaking puts them in a match, so the leaderboard holds people who have played.
 */
async function connect(body: Record<string, unknown>) {
  const steamId = String(body.steamId ?? "");
  if (!STEAM_ID.test(steamId)) throw new HttpError(400, "bad_steam_id");
  const player = must(
    await db.from("ranked_players").select("elo, games").eq("steam_id", steamId).maybeSingle(),
  ) as { elo: number; games: number } | null;
  return { ok: true, steamId, elo: player?.elo ?? START_ELO, games: player?.games ?? 0 };
}

// ---- Discord -----------------------------------------------------------------------------
//
// Optional: leave DISCORD_MATCHES_WEBHOOK / DISCORD_LEADERBOARD_WEBHOOK unset to switch a
// post off. Posts run after the reply is built and never throw into it, so Discord being
// down cannot lose or delay a result.

const MATCHES_WEBHOOK = Deno.env.get("DISCORD_MATCHES_WEBHOOK") ?? "";
const LEADERBOARD_WEBHOOK = Deno.env.get("DISCORD_LEADERBOARD_WEBHOOK") ?? "";
const LEADERBOARD_SIZE = 20;
const AGATHA_COLOUR = 0x3b82f6;
const MASON_COLOUR = 0xdc2626;
const NEUTRAL_COLOUR = 0x6b7280;

/** Run without holding up the reply; failures are logged, never thrown. */
function inBackground(task: () => Promise<unknown>) {
  const run = task().catch((e) => console.error("discord:", e));
  (globalThis as { EdgeRuntime?: { waitUntil(p: Promise<unknown>): void } }).EdgeRuntime?.waitUntil(run);
}

/** Player names are free text; keep them from turning into Discord formatting. */
const escapeMd = (text: string) => text.replace(/([\\*_`~|>#\[\]])/g, "\\$1");

const signed = (n: number) => (n > 0 ? `+${n}` : n < 0 ? `\u2212${-n}` : "\u00b10");

const statNum = (stats: unknown, key: string) =>
  Number((stats as Record<string, unknown> | undefined)?.[key] ?? 0) || 0;

/**
 * POST a new webhook message (returns its id), or PATCH an existing one. Returns null if the
 * message to edit is gone (deleted, or posted by an older webhook) so the caller can repost.
 */
async function discordSend(url: string, body: Record<string, unknown>, messageId?: string): Promise<string | null> {
  const res = await fetch(messageId ? `${url}/messages/${messageId}` : `${url}?wait=true`, {
    method: messageId ? "PATCH" : "POST",
    headers: { "Content-Type": "application/json" },
    // No pings: a player named "@everyone" must not ping the server.
    body: JSON.stringify({ allowed_mentions: { parse: [] }, ...body }),
  });
  if (messageId && res.status === 404) return null;
  if (!res.ok) throw new Error(`Discord ${res.status}: ${await res.text()}`);
  return ((await res.json()) as { id: string }).id;
}

function teamField(team: 1 | 2, match: MatchRow, lineup: MatchPlayer[], changes: Map<string, Change>, stats: Map<string, unknown>) {
  const avg = team === 1 ? match.team1_avg : match.team2_avg;
  const chance = Math.round(100 * (team === 1 ? match.team1_win_chance : 1 - match.team1_win_chance));

  const lines = lineup
    .filter((m) => m.team === team && changes.has(m.steam_id))
    .map((m) => ({ change: changes.get(m.steam_id)!, stats: stats.get(m.steam_id) }))
    .sort((a, b) => statNum(b.stats, "score") - statNum(a.stats, "score"))
    .map(({ change, stats }) => {
      const kda = stats
        ? `${statNum(stats, "kills")}/${statNum(stats, "deaths")}/${statNum(stats, "assists")} \u00b7 ${statNum(stats, "enemyDamage")} dmg`
        : "no stats";
      const left = change.result === "left" ? " \u00b7 **left**" : "";
      return `\`${signed(change.after - change.before).padStart(4)}\` **${escapeMd(change.name)}** ${change.after} \u00b7 ${kda}${left}`;
    });

  return {
    name: `${team === 1 ? "Agatha" : "Mason"} \u00b7 avg ${avg} \u00b7 ${chance}% predicted`,
    value: (lines.join("\n") || "\u2014").slice(0, 1024),
    inline: false,
  };
}

async function postMatchResult(match: MatchRow, lineup: MatchPlayer[], changes: Change[], stats: Map<string, unknown>) {
  if (!MATCHES_WEBHOOK) return;

  const s1 = match.team1_score;
  const s2 = match.team2_score;
  const scores = s1 !== null && s2 !== null;
  const outcome = match.winner === 1
    ? `**Agatha wins**${scores ? ` ${s1}\u2013${s2}` : ""}`
    : match.winner === 2
    ? `**Mason wins**${scores ? ` ${s2}\u2013${s1}` : ""}`
    : `**Draw**${scores ? ` ${s1}\u2013${s2}` : ""}`;

  const byId = new Map(changes.map((c) => [c.steamId, c]));
  await discordSend(MATCHES_WEBHOOK, {
    embeds: [{
      title: `Ranked ${match.team_size}v${match.team_size} \u00b7 ${match.map}`,
      description: outcome,
      color: match.winner === 1 ? AGATHA_COLOUR : match.winner === 2 ? MASON_COLOUR : NEUTRAL_COLOUR,
      fields: [teamField(1, match, lineup, byId, stats), teamField(2, match, lineup, byId, stats)],
      footer: { text: `${match.server} \u00b7 K/D/A \u00b7 damage to enemies` },
      timestamp: match.finished_at ?? new Date().toISOString(),
    }],
  });
}

async function postAbandoned(match: MatchRow, changes: Change[], stats: Map<string, unknown>) {
  if (!MATCHES_WEBHOOK) return;

  const leavers = changes
    .filter((c) => c.result === "left")
    .map((c) => {
      const s = stats.get(c.steamId);
      const kda = s
        ? ` \u00b7 ${statNum(s, "kills")}/${statNum(s, "deaths")}/${statNum(s, "assists")} \u00b7 ${statNum(s, "enemyDamage")} dmg`
        : "";
      return `**${escapeMd(c.name)}** left \u00b7 ${signed(c.after - c.before)} (${c.after})${kda}`;
    });

  await discordSend(MATCHES_WEBHOOK, {
    embeds: [{
      title: `Ranked ${match.team_size}v${match.team_size} abandoned \u00b7 ${match.map}`,
      description: [...leavers, "No Elo changes for anyone else."].join("\n"),
      color: NEUTRAL_COLOUR,
      footer: { text: match.server },
      timestamp: match.finished_at ?? new Date().toISOString(),
    }],
  });
}

/**
 * Post every finished and abandoned match so far, oldest first, from what the database
 * already holds. One-off for matches played before the webhook existed: running it again
 * posts them all again. Spaced out to stay under Discord's webhook rate limit.
 */
async function postHistory(): Promise<number> {
  if (!MATCHES_WEBHOOK) throw new Error("DISCORD_MATCHES_WEBHOOK is not set");

  const matches = must(
    await db
      .from("ranked_matches")
      .select("*")
      .in("status", ["completed", "abandoned"])
      .order("finished_at", { ascending: true }),
  ) as MatchRow[];

  for (const match of matches) {
    const rows = must(
      await db
        .from("ranked_match_players")
        .select("steam_id, team, elo_before, elo_after, result, stats")
        .eq("match_id", match.id),
    ) as (MatchPlayer & { elo_after: number | null; result: Outcome | null; stats: unknown })[];

    const players = await loadPlayers(rows.map((r) => r.steam_id));
    const changes: Change[] = rows.map((r) => ({
      steamId: r.steam_id,
      name: players.get(r.steam_id)?.name ?? r.steam_id,
      before: r.elo_before,
      after: r.elo_after ?? r.elo_before,
      result: r.result ?? "void",
    }));

    const stats = new Map<string, unknown>(rows.filter((r) => r.stats).map((r) => [r.steam_id, r.stats]));
    if (match.status === "completed") {
      await postMatchResult(match, rows, changes, stats);
    } else {
      await postAbandoned(match, changes, stats);
    }
    await new Promise((resolve) => setTimeout(resolve, 2000));
  }
  return matches.length;
}

/** One leaderboard message, edited in place after every match. Its id lives in ranked_settings. */
async function updateLeaderboard() {
  if (!LEADERBOARD_WEBHOOK) return;

  const top = must(
    await db
      .from("ranked_players")
      .select("name, elo, games, wins, losses, draws")
      .gt("games", 0)
      .order("elo", { ascending: false })
      .limit(LEADERBOARD_SIZE),
  ) as Pick<Player, "name" | "elo" | "games" | "wins" | "losses" | "draws">[];

  const lines = top.map((p, i) => {
    const decided = p.wins + p.losses + p.draws;
    const winRate = decided > 0 ? Math.round((100 * (p.wins + 0.5 * p.draws)) / decided) : 0;
    return `\`${String(i + 1).padStart(2)}.\` **${escapeMd(p.name)}** \u2014 ${p.elo} \u00b7 ${p.games} games \u00b7 ${winRate}% wins`;
  });

  const body = {
    embeds: [{
      title: "Ranked leaderboard",
      description: lines.join("\n") || "No ranked matches played yet.",
      color: AGATHA_COLOUR,
      footer: { text: "Updated after every ranked match" },
      timestamp: new Date().toISOString(),
    }],
  };

  const stored = must(
    await db.from("ranked_settings").select("value").eq("key", "leaderboard_message_id").maybeSingle(),
  ) as { value: string } | null;

  const editedId = stored ? await discordSend(LEADERBOARD_WEBHOOK, body, stored.value) : null;
  if (editedId) return;

  const newId = await discordSend(LEADERBOARD_WEBHOOK, body);
  must(await db.from("ranked_settings").upsert({ key: "leaderboard_message_id", value: newId }));
}

// ---- Entry point -------------------------------------------------------------------------

Deno.serve(async (req) => {
  try {
    if (req.method !== "POST") throw new HttpError(405, "method_not_allowed");

    const server = serverByToken.get(req.headers.get("x-server-token") ?? "");
    if (!server) throw new HttpError(401, "unauthorized");

    const body = await req.json().catch(() => null);
    if (body === null || typeof body !== "object") throw new HttpError(400, "bad_json");

    switch (new URL(req.url).pathname.split("/").filter(Boolean).pop()) {
      case "ping":
        return reply({ ok: true, server, time: new Date().toISOString() });
      case "connect":
        return reply(await connect(body));
      case "matchmake":
        return reply(await matchmake(server, body));
      case "result":
        return reply(await result(server, body));
      case "abandon":
        return reply(await abandon(server, body));
      case "cancel":
        return reply(await cancel(server, body));
      case "history":
        // One-off: post every past match to the match-history channel.
        try {
          return reply({ ok: true, posted: await postHistory() });
        } catch (e) {
          return reply({ ok: false, error: String(e) }, 502);
        }
      case "leaderboard":
        // Manual refresh, also the way to test the webhook: errors come back in the reply.
        try {
          await updateLeaderboard();
          return reply({ ok: true });
        } catch (e) {
          return reply({ ok: false, error: String(e) }, 502);
        }
      default:
        throw new HttpError(404, "unknown_action");
    }
  } catch (e) {
    if (e instanceof HttpError) return reply({ ok: false, error: e.message }, e.status);
    console.error(e);
    return reply({ ok: false, error: "internal_error" }, 500);
  }
});
