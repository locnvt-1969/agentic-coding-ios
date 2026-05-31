-- Awards: extends the existing public.awards (20260529000000_create_awards.sql)
-- with criteria lines and per-user recipients.

-- Existing awards policy only granted SELECT to anon; authenticated users need read too.
create policy "awards_read_authenticated" on public.awards
    for select to authenticated using (true);

create table if not exists public.award_criteria (
    id            uuid primary key default gen_random_uuid(),
    award_id      text not null references public.awards(id) on delete cascade,
    line_text     text not null,
    display_order int  not null default 0
);
alter table public.award_criteria enable row level security;
create policy "award_criteria_read_all" on public.award_criteria
    for select using (true);

create table if not exists public.award_recipients (
    id         uuid primary key default gen_random_uuid(),
    award_id   text not null references public.awards(id) on delete cascade,
    profile_id uuid not null references public.profiles(id) on delete cascade,
    year       int  not null default 2025,
    created_at timestamptz not null default now(),
    unique (award_id, profile_id, year)
);
create index if not exists award_recipients_profile_idx on public.award_recipients (profile_id);
alter table public.award_recipients enable row level security;
create policy "award_recipients_read_authenticated" on public.award_recipients
    for select to authenticated using (true);
