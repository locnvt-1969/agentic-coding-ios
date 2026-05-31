-- Gamification: value icons, user collection, secret boxes, hero tiers, mystery rewards.

create table if not exists public.value_icons (        -- the 6 Sun* icons (SunValueIcon)
    id            text primary key,                    -- 'revival','touch_of_light',...
    label         text not null,                       -- 'REVIVAL'
    image_name    text not null,                       -- 'rules_icon_revival'
    display_order int  not null default 0
);
alter table public.value_icons enable row level security;
create policy "value_icons_read_all" on public.value_icons
    for select using (true);

create table if not exists public.user_value_icons (   -- collection per user (req 6/7)
    profile_id    uuid not null references public.profiles(id) on delete cascade,
    value_icon_id text not null references public.value_icons(id) on delete cascade,
    earned_at     timestamptz not null default now(),
    primary key (profile_id, value_icon_id)
);
alter table public.user_value_icons enable row level security;
-- Readable by any authenticated user (other profiles show their collection); writes via RPC only.
create policy "user_value_icons_read_authenticated" on public.user_value_icons
    for select to authenticated using (true);

do $$ begin
    create type public.secret_box_state as enum ('closed','opening','standby','opened');
exception when duplicate_object then null; end $$;

create table if not exists public.secret_boxes (       -- 1 spin per 5 ❤️ received (req 6)
    id                   uuid primary key default gen_random_uuid(),
    profile_id           uuid not null references public.profiles(id) on delete cascade,
    state                public.secret_box_state not null default 'closed',
    reward_value_icon_id text references public.value_icons(id),
    created_at           timestamptz not null default now(),
    opened_at            timestamptz
);
create index if not exists secret_boxes_profile_idx on public.secret_boxes (profile_id, state);
alter table public.secret_boxes enable row level security;
create policy "secret_boxes_read_own" on public.secret_boxes
    for select to authenticated using (profile_id = auth.uid());

create table if not exists public.hero_tiers (         -- New/Rising/Super/Legend (req 5)
    id            text primary key,                    -- 'new','rising','super','legend'
    label         text not null,
    min_senders   int  not null,                       -- 1, 5, 10, 21
    max_senders   int,                                  -- 4, 9, 20, null(=∞)
    description   text not null,
    display_order int  not null default 0
);
alter table public.hero_tiers enable row level security;
create policy "hero_tiers_read_all" on public.hero_tiers
    for select using (true);

create table if not exists public.rewards (            -- mystery gifts (req 7, 8)
    id          text primary key,                      -- 'icon_collection','national_kudos'
    title       text not null,
    description text
);
alter table public.rewards enable row level security;
create policy "rewards_read_all" on public.rewards
    for select using (true);

create table if not exists public.user_rewards (       -- granted gifts
    id         uuid primary key default gen_random_uuid(),
    profile_id uuid not null references public.profiles(id) on delete cascade,
    reward_id  text not null references public.rewards(id) on delete cascade,
    kudo_id    uuid references public.kudos(id) on delete set null,  -- set for national_kudos
    granted_at timestamptz not null default now(),
    unique (profile_id, reward_id, kudo_id)
);
alter table public.user_rewards enable row level security;
create policy "user_rewards_read_own" on public.user_rewards
    for select to authenticated using (profile_id = auth.uid());
