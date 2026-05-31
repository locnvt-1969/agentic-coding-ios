create table if not exists public.awards (
    id text primary key,
    name text not null,
    description text not null,
    thumbnail_name text not null,
    display_order int not null default 0,
    created_at timestamptz not null default now()
);
alter table public.awards enable row level security;
create policy "Anon can read awards" on public.awards for select to anon using (true);
