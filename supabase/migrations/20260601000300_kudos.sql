-- Kudos domain: hashtags, kudos (single recipient), kudo_hashtags, kudo_reactions, kudo_comments.

create table if not exists public.hashtags (
    id         text primary key,        -- 'dedicated'
    name       text not null,           -- '#Dedicated'
    "group"    text,
    created_at timestamptz not null default now()
);
alter table public.hashtags enable row level security;
create policy "hashtags_read_all" on public.hashtags
    for select using (true);

create table if not exists public.kudos (
    id           uuid primary key default gen_random_uuid(),
    sender_id    uuid references public.profiles(id) on delete set null,
    recipient_id uuid not null references public.profiles(id) on delete cascade,
    title        text,                  -- danh hiệu (tiêu đề tự đặt)
    message      text not null,
    is_anonymous boolean not null default false,
    is_spam      boolean not null default false,
    created_at   timestamptz not null default now()
);
create index if not exists kudos_created_idx   on public.kudos (created_at desc);
create index if not exists kudos_sender_idx     on public.kudos (sender_id);
create index if not exists kudos_recipient_idx  on public.kudos (recipient_id);
alter table public.kudos enable row level security;
-- App reads via the kudos_public view (anonymity-respecting); raw read still allowed to
-- authenticated for insert-returning. Inserts must be authored by the signed-in sender.
create policy "kudos_read_authenticated" on public.kudos
    for select to authenticated using (true);
create policy "kudos_insert_own" on public.kudos
    for insert to authenticated with check (sender_id = auth.uid());

create table if not exists public.kudo_hashtags (
    kudo_id    uuid not null references public.kudos(id) on delete cascade,
    hashtag_id text not null references public.hashtags(id) on delete cascade,
    primary key (kudo_id, hashtag_id)
);
alter table public.kudo_hashtags enable row level security;
create policy "kudo_hashtags_read_all" on public.kudo_hashtags
    for select using (true);
create policy "kudo_hashtags_insert_by_author" on public.kudo_hashtags
    for insert to authenticated
    with check (exists (select 1 from public.kudos k where k.id = kudo_id and k.sender_id = auth.uid()));

create table if not exists public.kudo_reactions (   -- ❤️ — 1 per user, removable
    id         uuid primary key default gen_random_uuid(),
    kudo_id    uuid not null references public.kudos(id) on delete cascade,
    profile_id uuid not null references public.profiles(id) on delete cascade,
    created_at timestamptz not null default now(),
    unique (kudo_id, profile_id)
);
create index if not exists kudo_reactions_kudo_idx on public.kudo_reactions (kudo_id);
alter table public.kudo_reactions enable row level security;
create policy "kudo_reactions_read_authenticated" on public.kudo_reactions
    for select to authenticated using (true);
create policy "kudo_reactions_insert_own" on public.kudo_reactions
    for insert to authenticated with check (profile_id = auth.uid());
create policy "kudo_reactions_delete_own" on public.kudo_reactions
    for delete to authenticated using (profile_id = auth.uid());

create table if not exists public.kudo_comments (
    id         uuid primary key default gen_random_uuid(),
    kudo_id    uuid not null references public.kudos(id) on delete cascade,
    author_id  uuid not null references public.profiles(id) on delete cascade,
    text       text not null,
    created_at timestamptz not null default now()
);
create index if not exists kudo_comments_kudo_idx on public.kudo_comments (kudo_id);
alter table public.kudo_comments enable row level security;
create policy "kudo_comments_read_authenticated" on public.kudo_comments
    for select to authenticated using (true);
create policy "kudo_comments_insert_own" on public.kudo_comments
    for insert to authenticated with check (author_id = auth.uid());
create policy "kudo_comments_modify_own" on public.kudo_comments
    for update to authenticated using (author_id = auth.uid()) with check (author_id = auth.uid());
create policy "kudo_comments_delete_own" on public.kudo_comments
    for delete to authenticated using (author_id = auth.uid());
