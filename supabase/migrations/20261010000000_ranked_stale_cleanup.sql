-- Closes ranked matches left in_progress for over 3 hours (server crash). Void for everyone,
-- no Elo change. Requires pg_cron: enable it under Integrations > Cron before db push.

create or replace function public.ranked_close_stale_matches()
returns void
language sql
security definer
set search_path = public
as $$
  with stale as (
    update public.ranked_matches
    set status = 'abandoned', finished_at = now()
    where status = 'in_progress' and created_at < now() - interval '3 hours'
    returning id
  )
  update public.ranked_match_players mp
  set result = 'void', elo_after = mp.elo_before
  from stale
  where mp.match_id = stale.id;
$$;

revoke execute on function public.ranked_close_stale_matches() from public, anon, authenticated;

select cron.schedule('ranked-close-stale', '*/15 * * * *', 'select public.ranked_close_stale_matches()');
