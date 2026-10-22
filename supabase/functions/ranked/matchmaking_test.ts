// deno test supabase/functions/ranked/matchmaking_test.ts
import { assert, assertEquals } from "jsr:@std/assert@1.0.13";
import { balance, eloDelta, expectedScore, pickLargestMatch, pickPlayers, type Player } from "./matchmaking.ts";

let nextId = 0;
function player(elo: number, games = 30): Player {
  return { steam_id: String(++nextId), name: `p${nextId}`, elo, games, wins: 0, losses: 0, draws: 0, leaves: 0 };
}

const hasLowVeteran = (ps: Player[]) => ps.some((p) => p.games > 15 && p.elo < 2000);
const hasElite = (ps: Player[]) => ps.some((p) => p.elo > 3000);

Deno.test("a low-Elo veteran is never matched with a 3000+ player", () => {
  const queue = [player(3100), player(1900), ...Array.from({ length: 8 }, () => player(2500))];
  const picked = pickPlayers(queue, 4)!;
  assert(!(hasLowVeteran(picked) && hasElite(picked)));
});

Deno.test("the rule does not apply with 15 games or fewer", () => {
  const queue = [player(3100), player(1900, 15), player(2500), player(2500)];
  const picked = pickPlayers(queue, 4)!;
  assertEquals(picked.length, 4);
});

Deno.test("16 games is past the exemption", () => {
  const queue = [player(3100), player(1900, 16), player(2500), player(2500)];
  assertEquals(pickPlayers(queue, 4), null);
});

Deno.test("exactly 2000 and exactly 3000 are allowed together", () => {
  const queue = [player(3000), player(2000), player(2500), player(2500)];
  assertEquals(pickPlayers(queue, 4)?.length, 4);
});

Deno.test("an early elite player does not strand a full match of low veterans", () => {
  const queue = [player(3100), ...Array.from({ length: 4 }, () => player(1800))];
  const picked = pickPlayers(queue, 4)!;
  assertEquals(picked.length, 4);
  assert(!hasElite(picked));
});

Deno.test("queue order is kept when nobody conflicts", () => {
  const queue = Array.from({ length: 6 }, () => player(2500));
  assertEquals(pickPlayers(queue, 4)!.map((p) => p.steam_id), queue.slice(0, 4).map((p) => p.steam_id));
});

Deno.test("balance finds the fairest 5v5 split", () => {
  const players = [3000, 2900, 2600, 2500, 2500, 2400, 2400, 2300, 2100, 2000].map((e) => player(e));
  const [a, b] = balance(players);
  assertEquals(a.length, 5);
  assertEquals(b.length, 5);
  const sum = (t: Player[]) => t.reduce((s, p) => s + p.elo, 0);
  // Total 24700 and every Elo is a multiple of 100, so 100 apart is the best possible.
  assertEquals(Math.abs(sum(a) - sum(b)), 100);
});

Deno.test("greedy balance above the exhaustive limit still gives equal sizes", () => {
  const players = Array.from({ length: 24 }, (_, i) => player(2000 + i * 37));
  const [a, b] = balance(players);
  assertEquals(a.length, 12);
  assertEquals(b.length, 12);
});

Deno.test("Elo: even teams move 16 for veterans and 24 for new players", () => {
  assertEquals(expectedScore(2500, 2500), 0.5);
  assertEquals(eloDelta(30, 1, 0.5), 16);
  assertEquals(eloDelta(30, 0, 0.5), -16);
  assertEquals(eloDelta(3, 1, 0.5), 24);
});

Deno.test("match size follows the queue: 6 queued is a 3v3", () => {
  const queue = Array.from({ length: 6 }, () => player(2500));
  assertEquals(pickLargestMatch(queue, 1, 16)?.length, 6);
});

Deno.test("an odd queue leaves out the latest joiner", () => {
  const queue = Array.from({ length: 7 }, () => player(2500));
  const picked = pickLargestMatch(queue, 1, 16)!;
  assertEquals(picked.length, 6);
  assert(!picked.includes(queue[6]));
});

Deno.test("the max team size caps the match", () => {
  const queue = Array.from({ length: 12 }, () => player(2500));
  assertEquals(pickLargestMatch(queue, 1, 5)?.length, 10);
});

Deno.test("below the minimum there is no match", () => {
  const queue = Array.from({ length: 3 }, () => player(2500));
  assertEquals(pickLargestMatch(queue, 2, 16), null);
});

Deno.test("the skill-gap rule shrinks the match instead of blocking it", () => {
  // 1 elite + 1 low veteran + 4 normal: 6 together is illegal, a 4 or 5 player set is not.
  const queue = [player(3100), player(1900), ...Array.from({ length: 4 }, () => player(2500))];
  const picked = pickLargestMatch(queue, 1, 16)!;
  assertEquals(picked.length, 4);
  assert(!(hasLowVeteran(picked) && hasElite(picked)));
});
