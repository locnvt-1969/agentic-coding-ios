-- Improve list_kudos: read from the kudos_public view (single source of the anonymity
-- rule — sender_id already nulled there), cap the page size, and add optional
-- recipient/sender filters (used by the profile's received/sent kudos).

drop function if exists public.list_kudos(int, int);

create or replace function public.list_kudos(
    p_limit     int  default 20,
    p_offset    int  default 0,
    p_recipient uuid default null,
    p_sender    uuid default null
)
returns json
language sql
stable
security definer
set search_path = public
as $$
    with page as (
        select * from public.kudos_public k
        where (p_recipient is null or k.recipient_id = p_recipient)
          and (p_sender    is null or k.sender_id    = p_sender)
        order by k.created_at desc
        limit least(greatest(p_limit, 1), 100) offset greatest(p_offset, 0)
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
                'reaction_count', ku.reaction_count,
                'sender', case when ku.sender_id is null then null else (
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

revoke execute on function public.list_kudos(int, int, uuid, uuid) from public;
grant  execute on function public.list_kudos(int, int, uuid, uuid) to authenticated;
