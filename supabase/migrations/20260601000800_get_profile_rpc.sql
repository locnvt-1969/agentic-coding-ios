-- get_profile(p_id): one-call composed profile for the Profile screen —
-- profile + department + hero tier (distinct senders) + collected value icons + stats.
-- Returns null when no profile matches. SECURITY DEFINER so the aggregation views
-- (which span all profiles) resolve regardless of the caller.

create or replace function public.get_profile(p_id uuid)
returns json
language sql
stable
security definer
set search_path = public
as $$
    select json_build_object(
        'id',              p.id,
        'full_name',       p.full_name,
        'avatar_url',      p.avatar_url,
        'department_name', d.name,
        'role',            p.role,
        'hero_label',      ht.hero_label,
        'value_icon_ids',  coalesce(
            (select array_agg(uvi.value_icon_id order by vi.display_order)
             from public.user_value_icons uvi
             join public.value_icons vi on vi.id = uvi.value_icon_id
             where uvi.profile_id = p.id),
            array[]::text[]
        ),
        'stats', json_build_object(
            'kudos_received',      coalesce(st.kudos_received, 0),
            'kudos_sent',          coalesce(st.kudos_sent, 0),
            'hearts_received',     coalesce(st.hearts_received, 0),
            'secret_box_opened',   coalesce(st.secret_box_opened, 0),
            'secret_box_unopened', coalesce(st.secret_box_unopened, 0)
        )
    )
    from public.profiles p
    left join public.departments     d  on d.id = p.department_id
    left join public.v_user_hero_tier ht on ht.profile_id = p.id
    left join public.v_profile_stats  st on st.profile_id = p.id
    where p.id = p_id;
$$;

-- Authenticated only: SECURITY DEFINER bypasses the views' RLS, so do NOT expose
-- profile stats/hero-tier to anonymous callers (the app is login-gated).
-- Postgres grants functions to PUBLIC by default — revoke that first, then grant.
revoke execute on function public.get_profile(uuid) from public;
grant  execute on function public.get_profile(uuid) to authenticated;
