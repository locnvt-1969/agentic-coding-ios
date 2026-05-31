-- Notifications: per-user feed. Read own, mark own read. Inserts via triggers (service-defined).

do $$ begin
    create type public.notification_kind as enum
        ('kudo_received','kudo_reaction','award_granted','reward_granted','system');
exception when duplicate_object then null; end $$;

create table if not exists public.notifications (
    id              uuid primary key default gen_random_uuid(),
    recipient_id    uuid not null references public.profiles(id) on delete cascade,
    kind            public.notification_kind not null,
    actor_id        uuid references public.profiles(id) on delete set null,
    message         text not null,
    related_kudo_id uuid references public.kudos(id) on delete cascade,
    is_read         boolean not null default false,
    created_at      timestamptz not null default now()
);
create index if not exists notifications_recipient_idx on public.notifications (recipient_id, is_read);
alter table public.notifications enable row level security;
create policy "notifications_read_own" on public.notifications
    for select to authenticated using (recipient_id = auth.uid());
create policy "notifications_update_own" on public.notifications
    for update to authenticated using (recipient_id = auth.uid()) with check (recipient_id = auth.uid());
