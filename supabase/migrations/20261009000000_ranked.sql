-- SlumpMod ranked LTS (ported from MustMod). Written only by the `ranked` Edge Function (service role); the
-- players table is publicly readable so a leaderboard page can use the anon key.

create table public.ranked_players (
  steam_id    text primary key,                 -- SteamID64, decimal
  name        text not null default '',
  elo         integer not null default 2500,    -- starting Elo; keep in step with START_ELO
  games       integer not null default 0,       -- finished + left; drives the 15-game rules
  wins        integer not null default 0,
  losses      integer not null default 0,
  draws       integer not null default 0,
  leaves      integer not null default 0,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create table public.ranked_matches (
  id           uuid primary key default gen_random_uuid(),
  server       text not null,
  map          text not null default '',
  team_size    integer not null,
  status       text not null default 'in_progress'
               check (status in ('in_progress', 'completed', 'abandoned', 'cancelled')),
  winner       smallint check (winner in (0, 1, 2)),   -- 1 Agatha, 2 Mason, 0 draw

  -- Team strength when the match was made, for predicting outcomes. Team 1 = Agatha.
  team1_avg        integer not null,
  team2_avg        integer not null,
  team1_total      integer not null,
  team2_total      integer not null,
  elo_diff         integer generated always as (team1_avg - team2_avg) stored,
  team1_win_chance real not null,            -- what the Elo formula predicted, 0..1

  -- Rounds won, filled in with the result: the margin says more than win/loss alone.
  team1_score  integer,
  team2_score  integer,

  created_at   timestamptz not null default now(),
  finished_at  timestamptz
);

create table public.ranked_match_players (
  match_id    uuid not null references public.ranked_matches (id) on delete cascade,
  steam_id    text not null references public.ranked_players (steam_id),
  team        smallint not null check (team in (1, 2)),
  elo_before  integer not null,
  elo_after   integer,
  result      text check (result in ('win', 'loss', 'draw', 'left', 'void')),
  stats       jsonb,
  primary key (match_id, steam_id)
);

create index ranked_players_elo_idx on public.ranked_players (elo desc);
create index ranked_match_players_steam_idx on public.ranked_match_players (steam_id);

alter table public.ranked_players enable row level security;
alter table public.ranked_matches enable row level security;
alter table public.ranked_match_players enable row level security;

create policy "leaderboard is public" on public.ranked_players for select using (true);

-- One row per finished match, ready for checking how well Elo predicts the winner.
create view public.ranked_match_outcomes with (security_invoker = true) as
select
  id,
  created_at,
  map,
  team_size,
  team1_avg,
  team2_avg,
  team1_total,
  team2_total,
  elo_diff,
  team1_win_chance,
  winner,
  case winner when 1 then 1.0 when 2 then 0.0 else 0.5 end as team1_result,
  team1_score,
  team2_score
from public.ranked_matches
where status = 'completed';

-- Per-player stats for every ranked match, newest first. Run once in the SQL Editor;
-- afterwards it shows up as "ranked_match_stats" in the Table Editor.
create view public.ranked_match_stats with (security_invoker = true) as
select
  m.created_at                          as played_at,
  m.map,
  m.team_size,
  m.status,
  m.winner,
  mp.team,
  p.name,
  mp.result,
  mp.elo_before,
  mp.elo_after,
  mp.elo_after - mp.elo_before          as elo_change,
  (mp.stats ->> 'kills')::int           as kills,
  (mp.stats ->> 'deaths')::int          as deaths,
  (mp.stats ->> 'assists')::int         as assists,
  (mp.stats ->> 'enemyDamage')::int     as damage,
  (mp.stats ->> 'score')::int           as score,
  m.id                                  as match_id,
  mp.steam_id
from public.ranked_match_players mp
join public.ranked_matches m on m.id = mp.match_id
join public.ranked_players p on p.steam_id = mp.steam_id
order by m.created_at desc, m.id, mp.team, (mp.stats ->> 'score')::int desc nulls last;

-- Small key/value store for the ranked function. Holds the id of the Discord leaderboard
-- message so it can be edited in place. Function-only: RLS on, no policies.
create table public.ranked_settings (
  key    text primary key,
  value  text not null
);

alter table public.ranked_settings enable row level security;
