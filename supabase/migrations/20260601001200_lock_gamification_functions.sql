-- Security hardening: lock down gamification functions that Supabase default
-- privileges auto-granted EXECUTE to anon/authenticated on creation.
-- REVOKE FROM PUBLIC alone is not enough — the role-level grants must go too.

-- grant_national_kudos: end-of-program admin action that mints the top-5 "Kudos Quốc
-- Dân" rewards. Must NOT be callable by app users — privilege escalation otherwise.
-- Restrict to the function owner / service_role (run by an operator, never the client).
revoke execute on function public.grant_national_kudos() from public, anon, authenticated;

-- open_secret_box: legit caller is an authenticated user opening THEIR OWN box
-- (ownership re-checked via auth.uid() inside). Drop the unnecessary anon/public surface.
revoke execute on function public.open_secret_box(uuid) from public, anon;

-- Trigger functions: fired by the DB on row events; they never need a direct caller
-- grant. Keep them entirely off the PostgREST /rpc surface.
revoke execute on function public.grant_secret_boxes_on_heart()   from public, anon, authenticated;
revoke execute on function public.grant_icon_collection_reward()  from public, anon, authenticated;
revoke execute on function public.notify_kudo_received()          from public, anon, authenticated;
revoke execute on function public.notify_kudo_reaction()          from public, anon, authenticated;
revoke execute on function public.notify_award_granted()          from public, anon, authenticated;
revoke execute on function public.notify_reward_granted()         from public, anon, authenticated;
