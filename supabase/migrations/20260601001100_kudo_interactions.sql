-- Kudo interactions: a shared `kudo_json(id)` builder (DRY) used by both the list feed
-- and the new `view_kudo(p_id)` detail RPC. Adds `has_reacted` (current user) to the
-- shape. Reads from kudos_public (anonymity single-source). auth.uid() inside a
-- SECURITY DEFINER function still returns the CALLER's id (reads the request JWT).

-- ── Shared kudo JSON builder ─────────────────────────────────────────────────
create or replace function public.kudo_json(p_kudo_id uuid)
returns jsonb language sql stable security definer set search_path = public as $$
    select jsonb_build_object(
        'id', ku.id, 'title', ku.title, 'message', ku.message,
        'is_anonymous', ku.is_anonymous, 'is_spam', ku.is_spam, 'created_at', ku.created_at,
        'reaction_count', ku.reaction_count,
        'has_reacted', exists(
            select 1 from public.kudo_reactions r where r.kudo_id = ku.id and r.profile_id = auth.uid()
        ),
        'sender', case when ku.sender_id is null then null else (
            select jsonb_build_object('id', s.id, 'full_name', s.full_name, 'department_name', sd.name)
            from public.profiles s left join public.departments sd on sd.id = s.department_id
            where s.id = ku.sender_id
        ) end,
        'recipient', (
            select jsonb_build_object('id', r2.id, 'full_name', r2.full_name, 'department_name', rd.name)
            from public.profiles r2 left join public.departments rd on rd.id = r2.department_id
            where r2.id = ku.recipient_id
        ),
        'hashtags', coalesce((
            select jsonb_agg(jsonb_build_object('id', h.id, 'name', h.name))
            from public.kudo_hashtags kh join public.hashtags h on h.id = kh.hashtag_id
            where kh.kudo_id = ku.id
        ), '[]'::jsonb)
    )
    from public.kudos_public ku
    where ku.id = p_kudo_id;
$$;

-- ── list_kudos: now uses kudo_json + carries has_reacted ─────────────────────
drop function if exists public.list_kudos(int, int, uuid, uuid);

create or replace function public.list_kudos(
    p_limit int default 20, p_offset int default 0,
    p_recipient uuid default null, p_sender uuid default null
)
returns json language sql stable security definer set search_path = public as $$
    with page as (
        select id, created_at from public.kudos_public k
        where (p_recipient is null or k.recipient_id = p_recipient)
          and (p_sender    is null or k.sender_id    = p_sender)
        order by k.created_at desc
        limit least(greatest(p_limit, 1), 100) offset greatest(p_offset, 0)
    )
    select coalesce(json_agg(public.kudo_json(page.id) order by page.created_at desc), '[]'::json)
    from page;
$$;

-- ── view_kudo(p_id): one kudo + comments ─────────────────────────────────────
-- CTE evaluates kudo_json once (it fans out to several correlated subqueries), then
-- both the null-guard and the merge read that single result.
create or replace function public.view_kudo(p_id uuid)
returns json language sql stable security definer set search_path = public as $$
    with base as (select public.kudo_json(p_id) as kj)
    select (base.kj || jsonb_build_object(
        'comments', coalesce((
            select jsonb_agg(jsonb_build_object(
                'id', c.id, 'text', c.text, 'created_at', c.created_at,
                'author', jsonb_build_object('id', ca.id, 'full_name', ca.full_name, 'department_name', cad.name)
            ) order by c.created_at asc)
            from public.kudo_comments c
            join public.profiles ca on ca.id = c.author_id
            left join public.departments cad on cad.id = ca.department_id
            where c.kudo_id = p_id
        ), '[]'::jsonb)
    ))::json
    from base
    where base.kj is not null;
$$;

-- kudo_json is an internal helper — SECURITY DEFINER callers (list_kudos/view_kudo) run
-- as the owner, so it needs no direct grant. Revoke from anon/authenticated too:
-- Supabase default privileges auto-grant EXECUTE on new functions to those roles, so
-- REVOKE FROM PUBLIC alone would leave it callable over the PostgREST /rpc surface.
revoke execute on function public.kudo_json(uuid) from public, anon, authenticated;
revoke execute on function public.list_kudos(int, int, uuid, uuid) from public;
grant  execute on function public.list_kudos(int, int, uuid, uuid) to authenticated;
revoke execute on function public.view_kudo(uuid) from public;
grant  execute on function public.view_kudo(uuid) to authenticated;
