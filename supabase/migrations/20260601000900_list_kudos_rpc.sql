-- list_kudos(p_limit, p_offset): paginated kudos feed as composed JSON.
-- Anonymity enforced in SQL (sender = null when is_anonymous). Embeds sender/recipient
-- (profile + department), hashtags, and reaction_count — PostgREST can't embed from the
-- kudos_public view, so this RPC owns the shape. Newest first.

create or replace function public.list_kudos(p_limit int default 20, p_offset int default 0)
returns json
language sql
stable
security definer
set search_path = public
as $$
    with page as (
        select * from public.kudos order by created_at desc limit p_limit offset p_offset
    )
    select coalesce(
        json_agg(
            json_build_object(
                'id',             ku.id,
                'title',          ku.title,
                'message',        ku.message,
                'is_anonymous',   ku.is_anonymous,
                'is_spam',        ku.is_spam,
                'created_at',     ku.created_at,
                'reaction_count', (select count(*) from public.kudo_reactions r where r.kudo_id = ku.id),
                'sender', case when ku.is_anonymous then null else (
                    select json_build_object('id', s.id, 'full_name', s.full_name, 'department_name', sd.name)
                    from public.profiles s
                    left join public.departments sd on sd.id = s.department_id
                    where s.id = ku.sender_id
                ) end,
                'recipient', (
                    select json_build_object('id', r2.id, 'full_name', r2.full_name, 'department_name', rd.name)
                    from public.profiles r2
                    left join public.departments rd on rd.id = r2.department_id
                    where r2.id = ku.recipient_id
                ),
                'hashtags', coalesce((
                    select json_agg(json_build_object('id', h.id, 'name', h.name))
                    from public.kudo_hashtags kh
                    join public.hashtags h on h.id = kh.hashtag_id
                    where kh.kudo_id = ku.id
                ), '[]'::json)
            )
            order by ku.created_at desc
        ),
        '[]'::json
    )
    from page ku;
$$;

revoke execute on function public.list_kudos(int, int) from public;
grant  execute on function public.list_kudos(int, int) to authenticated;
