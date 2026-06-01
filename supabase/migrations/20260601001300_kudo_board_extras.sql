-- Kudos board extras: server-side hashtag/department filter on the feed, plus a
-- recent-gift-recipients view (user_rewards is RLS-locked to the owner, so a global
-- "10 newest reward recipients" list needs an owner-rights view).

-- ── list_kudos: add hashtag + department filters ─────────────────────────────
-- New 6-arg signature replaces the 4-arg one. p_hashtag = hashtags.id (text);
-- p_department = departments.id (text), matched against the RECIPIENT's department.
drop function if exists public.list_kudos(int, int, uuid, uuid);

create or replace function public.list_kudos(
    p_limit int default 20, p_offset int default 0,
    p_recipient uuid default null, p_sender uuid default null,
    p_hashtag text default null, p_department text default null
)
returns json language sql stable security definer set search_path = public as $$
    with page as (
        select k.id, k.created_at from public.kudos_public k
        where (p_recipient is null or k.recipient_id = p_recipient)
          and (p_sender    is null or k.sender_id    = p_sender)
          and (p_hashtag is null or exists (
                select 1 from public.kudo_hashtags kh
                where kh.kudo_id = k.id and kh.hashtag_id = p_hashtag))
          and (p_department is null or exists (
                select 1 from public.profiles pr
                where pr.id = k.recipient_id and pr.department_id = p_department))
        order by k.created_at desc
        limit least(greatest(p_limit, 1), 100) offset greatest(p_offset, 0)
    )
    select coalesce(json_agg(public.kudo_json(page.id) order by page.created_at desc), '[]'::json)
    from page;
$$;

revoke execute on function public.list_kudos(int, int, uuid, uuid, text, text) from public, anon;
grant  execute on function public.list_kudos(int, int, uuid, uuid, text, text) to authenticated;

-- ── Recent gift recipients (design D.3) ──────────────────────────────────────
-- Owner-rights view (bypasses user_rewards RLS) so the board can show everyone's
-- newest rewards; access gated by the explicit GRANT below.
-- Selects only display fields (no profile_id, no granted_at) — newest first.
create or replace view public.v_recent_gift_recipients as
select ur.id,
       p.full_name   as name,
       p.avatar_url  as avatar_url,
       r.title       as reward_text
from public.user_rewards ur
join public.profiles p on p.id = ur.profile_id
join public.rewards  r on r.id = ur.reward_id
order by ur.granted_at desc
limit 10;

grant select on public.v_recent_gift_recipients to authenticated;
