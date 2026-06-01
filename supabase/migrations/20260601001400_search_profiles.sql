-- Diacritic-insensitive Sunner search. The previous approach (PostgREST ilike on
-- full_name) was accent-sensitive, so typing "Nguyen" never matched "Nguyễn".
-- This RPC normalises both sides with unaccent. An empty query returns the first
-- page of the directory (so the recipient picker / search isn't blank before typing).

create extension if not exists unaccent with schema extensions;

create or replace function public.search_profiles(p_query text default '', p_limit int default 50)
returns table (id uuid, full_name text, avatar_url text, role text, department_name text)
language sql stable security definer set search_path = public, extensions as $$
    select p.id, p.full_name, p.avatar_url, p.role, d.name
    from public.profiles p
    left join public.departments d on d.id = p.department_id
    where p.full_name <> ''
      and (
          nullif(btrim(p_query), '') is null
          or extensions.unaccent(p.full_name) ilike '%' || extensions.unaccent(btrim(p_query)) || '%'
      )
    order by p.full_name asc
    limit least(greatest(p_limit, 1), 100);
$$;

revoke execute on function public.search_profiles(text, int) from public, anon;
grant  execute on function public.search_profiles(text, int) to authenticated;
