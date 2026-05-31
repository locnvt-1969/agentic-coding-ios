-- Identity & org: departments + profiles (extends auth.users) + signup trigger.
-- Reference table (departments) = public read. profiles = authenticated read, update own.

create table if not exists public.departments (
    id   text primary key,            -- 'cevc3'
    name text not null                -- 'CEVC3'
);
alter table public.departments enable row level security;
create policy "departments_read_all" on public.departments
    for select using (true);

create table if not exists public.profiles (
    id            uuid primary key references auth.users(id) on delete cascade,
    full_name     text not null default '',
    avatar_url    text,
    department_id text references public.departments(id),
    role          text,
    created_at    timestamptz not null default now(),
    updated_at    timestamptz not null default now()
);
alter table public.profiles enable row level security;
create policy "profiles_read_authenticated" on public.profiles
    for select to authenticated using (true);
create policy "profiles_update_own" on public.profiles
    for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);

-- Auto-provision a profile row when a new auth user is created (Google OAuth signup).
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
    insert into public.profiles (id, full_name, avatar_url)
    values (
        new.id,
        coalesce(new.raw_user_meta_data ->> 'full_name', new.raw_user_meta_data ->> 'name', ''),
        new.raw_user_meta_data ->> 'avatar_url'
    )
    on conflict (id) do nothing;
    return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
    after insert on auth.users
    for each row execute function public.handle_new_user();
