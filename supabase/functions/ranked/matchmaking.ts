// Pure matchmaking and rating rules for the ranked function -- no database, so they can be
// unit-tested (matchmaking_test.ts) and tuned in one place.

// ---- Tunables ----------------------------------------------------------------------------

// New players start here. Keep in step with the ranked_players.elo column default.
export const START_ELO = 2500;
export const K_FACTOR = 32;
export const K_FACTOR_NEW = 48; // players still under PROVEN_GAMES move faster
export const PROVEN_GAMES = 15;
export const LEAVE_PENALTY = 50;

// Skill-gap rule: a player with more than PROVEN_GAMES games and under LOW_ELO may not be in
// a match with anyone over HIGH_ELO. Players with PROVEN_GAMES or fewer are exempt.
export const LOW_ELO = 2000;
export const HIGH_ELO = 3000;

// Team balancing tries every split up to this many players, then falls back to greedy.
export const EXHAUSTIVE_LIMIT = 20;

export type Player = {
  steam_id: string;
  name: string;
  elo: number;
  games: number;
  wins: number;
  losses: number;
  draws: number;
  leaves: number;
};

// ---- Matchmaking -------------------------------------------------------------------------

export const isRestricted = (p: Player) => p.games > PROVEN_GAMES && p.elo < LOW_ELO;
export const isElite = (p: Player) => p.elo > HIGH_ELO;

/** First-come-first-served, skipping anyone who would break the skill-gap rule. */
function pickGreedy(queue: Player[], n: number): Player[] | null {
  const picked: Player[] = [];
  let hasRestricted = false;
  let hasElite = false;

  for (const p of queue) {
    if (picked.length === n) break;
    const restricted = isRestricted(p);
    const elite = isElite(p);
    if ((restricted && hasElite) || (elite && hasRestricted)) continue;
    picked.push(p);
    hasRestricted ||= restricted;
    hasElite ||= elite;
  }
  return picked.length === n ? picked : null;
}

/**
 * Greedy in queue order can strand a full match: an early elite player blocks every
 * restricted player behind them. So also try each side of the rule on its own.
 */
export function pickPlayers(queue: Player[], n: number): Player[] | null {
  return (
    pickGreedy(queue, n) ??
    pickGreedy(queue.filter((p) => !isRestricted(p)), n) ??
    pickGreedy(queue.filter((p) => !isElite(p)), n)
  );
}

/**
 * The biggest even match the queue allows: every queued player if the count is even, all but
 * the latest joiner if it is odd, capped at maxTeamSize a side. If the skill-gap rule blocks
 * that size it steps down two players at a time, never below minTeamSize a side.
 */
export function pickLargestMatch(queue: Player[], minTeamSize: number, maxTeamSize: number): Player[] | null {
  const largest = Math.min(Math.floor(queue.length / 2), maxTeamSize);
  for (let teamSize = largest; teamSize >= minTeamSize; teamSize--) {
    const picked = pickPlayers(queue, teamSize * 2);
    if (picked) return picked;
  }
  return null;
}

/** Split into two equal teams with the smallest Elo difference. */
export function balance(players: Player[]): [Player[], Player[]] {
  const n = players.length;
  const size = n / 2;

  if (n <= EXHAUSTIVE_LIMIT) {
    const total = players.reduce((sum, p) => sum + p.elo, 0);
    let bestMask = 0;
    let bestDiff = Infinity;

    // Player 0 is always on team 1, which skips every mirror-image split.
    for (let mask = 1; mask < 1 << n; mask += 2) {
      let count = 0;
      let sum = 0;
      for (let i = 0; i < n; i++) {
        if (mask & (1 << i)) {
          count++;
          sum += players[i].elo;
        }
      }
      if (count !== size) continue;
      const diff = Math.abs(total - 2 * sum);
      if (diff < bestDiff) {
        bestDiff = diff;
        bestMask = mask;
      }
    }
    return [
      players.filter((_, i) => bestMask & (1 << i)),
      players.filter((_, i) => !(bestMask & (1 << i))),
    ];
  }

  const team1: Player[] = [];
  const team2: Player[] = [];
  let sum1 = 0;
  let sum2 = 0;
  for (const p of [...players].sort((a, b) => b.elo - a.elo)) {
    if (team2.length >= size || (team1.length < size && sum1 <= sum2)) {
      team1.push(p);
      sum1 += p.elo;
    } else {
      team2.push(p);
      sum2 += p.elo;
    }
  }
  return [team1, team2];
}

export const average = (team: Player[]) =>
  Math.round(team.reduce((sum, p) => sum + p.elo, 0) / team.length);

/** Elo change for one player: score is 1 win, 0.5 draw, 0 loss. */
export function eloDelta(games: number, score: number, expected: number): number {
  const k = games < PROVEN_GAMES ? K_FACTOR_NEW : K_FACTOR;
  return Math.round(k * (score - expected));
}

/** Probability that a team with average teamAvg beats one with average otherAvg. */
export function expectedScore(teamAvg: number, otherAvg: number): number {
  return 1 / (1 + 10 ** ((otherAvg - teamAvg) / 400));
}
