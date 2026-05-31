-- Derived views + business-rule functions/triggers/RPCs (reqs 4–8).
-- Views run with owner rights (bypass RLS) so they can aggregate across profiles
-- (needed to view OTHER users' stats/collection); access gated by explicit GRANTs.

-- ── Views ────────────────────────────────────────────────────────────────────

-- Anonymity invariant at the DB layer (mirrors Kudo.resolvedSender). App reads this.
create or replace view public.kudos_public as
select k.id, k.recipient_id, k.title, k.message, k.is_anonymous, k.is_spam, k.created_at,
       case when k.is_anonymous then null else k.sender_id end as sender_id,
       (select count(*) from public.kudo_reactions r where r.kudo_id = k.id) as reaction_count
from public.kudos k;

-- Profile stats (req 4). hearts_received = ❤️ on the user's SENT kudos (drives secret boxes).
create or replace view public.v_profile_stats as
select p.id as profile_id,
    (select count(*) from public.kudos k where k.recipient_id = p.id) as kudos_received,
    (select count(*) from public.kudos k where k.sender_id    = p.id) as kudos_sent,
    (select count(*) from public.kudo_reactions r
        join public.kudos k on k.id = r.kudo_id where k.sender_id = p.id) as hearts_received,
    (select count(*) from public.secret_boxes b where b.profile_id = p.id and b.state =  'opened') as secret_box_opened,
    (select count(*) from public.secret_boxes b where b.profile_id = p.id and b.state <> 'opened') as secret_box_unopened
from public.profiles p;

-- Hero tier (req 5) — by number of DISTINCT senders ("Có N người gửi").
create or replace view public.v_user_hero_tier as
select p.id as profile_id,
       (select t.label from public.hero_tiers t
        where s.cnt between t.min_senders and coalesce(t.max_senders, 2147483647)
        order by t.min_senders desc limit 1) as hero_label,
       s.cnt as distinct_senders
from public.profiles p
cross join lateral (
    select count(distinct k.sender_id) as cnt
    from public.kudos k where k.recipient_id = p.id and k.sender_id is not null
) s;

-- Kudos Quốc Dân (req 8) — top 5 by ❤️.
create or replace view public.v_national_kudos as
select * from public.kudos_public order by reaction_count desc, created_at asc limit 5;

grant select on public.kudos_public, public.v_profile_stats,
                public.v_user_hero_tier, public.v_national_kudos to authenticated;

-- ── Secret box grant: 1 box per 5 ❤️ received on the user's sent kudos (req 6) ──
create or replace function public.grant_secret_boxes_on_heart()
returns trigger language plpgsql security definer set search_path = public as $$
declare
    v_sender   uuid;
    v_hearts   int;
    v_target   int;
    v_existing int;
begin
    select sender_id into v_sender from public.kudos where id = new.kudo_id;
    if v_sender is null then return new; end if;

    select count(*) into v_hearts
    from public.kudo_reactions r
    join public.kudos k on k.id = r.kudo_id
    where k.sender_id = v_sender;

    v_target := v_hearts / 5;                       -- integer division = floor
    select count(*) into v_existing from public.secret_boxes where profile_id = v_sender;

    while v_existing < v_target loop
        insert into public.secret_boxes (profile_id, state) values (v_sender, 'closed');
        v_existing := v_existing + 1;
    end loop;
    return new;
end;
$$;

drop trigger if exists trg_grant_secret_boxes on public.kudo_reactions;
create trigger trg_grant_secret_boxes
    after insert on public.kudo_reactions
    for each row execute function public.grant_secret_boxes_on_heart();

-- ── Open a secret box: random icon NOT yet owned (req 6) ───────────────────────
create or replace function public.open_secret_box(p_box_id uuid)
returns public.value_icons language plpgsql security definer set search_path = public as $$
declare
    v_profile uuid;
    v_icon    public.value_icons%rowtype;
begin
    select profile_id into v_profile from public.secret_boxes
    where id = p_box_id and state <> 'opened' for update;

    if v_profile is null then raise exception 'Secret box not found or already opened'; end if;
    if v_profile <> auth.uid() then raise exception 'Not your secret box'; end if;

    select vi.* into v_icon from public.value_icons vi
    where not exists (
        select 1 from public.user_value_icons u
        where u.profile_id = v_profile and u.value_icon_id = vi.id
    )
    order by random() limit 1;

    update public.secret_boxes
       set state = 'opened', opened_at = now(), reward_value_icon_id = v_icon.id
     where id = p_box_id;

    if v_icon.id is not null then
        insert into public.user_value_icons (profile_id, value_icon_id)
        values (v_profile, v_icon.id) on conflict do nothing;
    end if;
    return v_icon;
end;
$$;
grant execute on function public.open_secret_box(uuid) to authenticated;

-- ── Mystery gift when all 6 icons collected (req 7) ────────────────────────────
create or replace function public.grant_icon_collection_reward()
returns trigger language plpgsql security definer set search_path = public as $$
declare v_count int;
begin
    select count(*) into v_count from public.user_value_icons where profile_id = new.profile_id;
    if v_count >= 6 and not exists (
        select 1 from public.user_rewards
        where profile_id = new.profile_id and reward_id = 'icon_collection'
    ) then
        insert into public.user_rewards (profile_id, reward_id) values (new.profile_id, 'icon_collection');
    end if;
    return new;
end;
$$;

drop trigger if exists trg_icon_collection on public.user_value_icons;
create trigger trg_icon_collection
    after insert on public.user_value_icons
    for each row execute function public.grant_icon_collection_reward();

-- ── Grant gift to the top-5 most-❤️ kudos' authors (req 8) — run at program close ──
create or replace function public.grant_national_kudos()
returns void language plpgsql security definer set search_path = public as $$
begin
    insert into public.user_rewards (profile_id, reward_id, kudo_id)
    select nk.sender_id, 'national_kudos', nk.id
    from public.v_national_kudos nk
    where nk.sender_id is not null
    on conflict (profile_id, reward_id, kudo_id) do nothing;
end;
$$;

-- ── Notifications (triggers) ───────────────────────────────────────────────────
create or replace function public.notify_kudo_received()
returns trigger language plpgsql security definer set search_path = public as $$
begin
    insert into public.notifications (recipient_id, kind, actor_id, message, related_kudo_id)
    values (new.recipient_id, 'kudo_received',
            case when new.is_anonymous then null else new.sender_id end,
            coalesce(nullif(new.title, ''), 'Bạn nhận được một Kudos'), new.id);
    return new;
end;
$$;
drop trigger if exists trg_notify_kudo_received on public.kudos;
create trigger trg_notify_kudo_received
    after insert on public.kudos for each row execute function public.notify_kudo_received();

create or replace function public.notify_kudo_reaction()
returns trigger language plpgsql security definer set search_path = public as $$
declare v_sender uuid;
begin
    select sender_id into v_sender from public.kudos where id = new.kudo_id;
    if v_sender is not null and v_sender <> new.profile_id then
        insert into public.notifications (recipient_id, kind, actor_id, message, related_kudo_id)
        values (v_sender, 'kudo_reaction', new.profile_id, 'đã thả tim cho Kudos của bạn', new.kudo_id);
    end if;
    return new;
end;
$$;
drop trigger if exists trg_notify_kudo_reaction on public.kudo_reactions;
create trigger trg_notify_kudo_reaction
    after insert on public.kudo_reactions for each row execute function public.notify_kudo_reaction();

create or replace function public.notify_award_granted()
returns trigger language plpgsql security definer set search_path = public as $$
begin
    insert into public.notifications (recipient_id, kind, message)
    values (new.profile_id, 'award_granted', 'Bạn được trao một giải thưởng');
    return new;
end;
$$;
drop trigger if exists trg_notify_award on public.award_recipients;
create trigger trg_notify_award
    after insert on public.award_recipients for each row execute function public.notify_award_granted();

create or replace function public.notify_reward_granted()
returns trigger language plpgsql security definer set search_path = public as $$
begin
    insert into public.notifications (recipient_id, kind, message, related_kudo_id)
    values (new.profile_id, 'reward_granted', 'Bạn nhận được phần quà bí ẩn từ chương trình', new.kudo_id);
    return new;
end;
$$;
drop trigger if exists trg_notify_reward on public.user_rewards;
create trigger trg_notify_reward
    after insert on public.user_rewards for each row execute function public.notify_reward_granted();
