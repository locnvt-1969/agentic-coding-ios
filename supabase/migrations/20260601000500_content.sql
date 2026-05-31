-- Static content: Community Standards + Rules (Thể lệ) text sections.
-- Maps ContentSection (with structured fields). Public read.

create table if not exists public.content_documents (
    id         text primary key,              -- 'community_standards','rules'
    title      text not null,                 -- 'Tiêu chuẩn chung','Thể lệ'
    updated_at timestamptz not null default now()
);
alter table public.content_documents enable row level security;
create policy "content_documents_read_all" on public.content_documents
    for select using (true);

create table if not exists public.content_sections (
    id             uuid primary key default gen_random_uuid(),
    document_id    text not null references public.content_documents(id) on delete cascade,
    title          text not null,
    lead_paragraph text,
    body           text[] not null default '{}',
    numbered_items text[] not null default '{}',
    bullet_items   text[] not null default '{}',
    highlight      text,
    display_order  int    not null default 0
);
create index if not exists content_sections_doc_idx on public.content_sections (document_id, display_order);
alter table public.content_sections enable row level security;
create policy "content_sections_read_all" on public.content_sections
    for select using (true);
