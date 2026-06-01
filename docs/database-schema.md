# Database Schema — Supabase (Postgres 17)

Derived from the current Swift models, services, screens, the "Thể lệ" (Rules) content,
and the 8 product requirements (§0). Builds on the existing
`supabase/migrations/20260529000000_create_awards.sql` + `seeds/awards.sql`.

**Conventions (matching existing code):**
- Reference / public-content tables → `text` slug PK, `anon`+`authenticated` SELECT, writes via `service_role`.
- User data → `uuid` PK, RLS keyed on `auth.uid()`.
- `profiles.id` = `auth.users.id` (Supabase Auth = identity; Google OAuth planned in `AuthService`).
- Derived values (Hero tier, profile stats, reaction counts) are **views/functions**, never stored — avoids drift.

---

## 0. Requirements → schema mapping

| # | Requirement | Schema element |
|---|---|---|
| 1 | Many users, must log in | `auth.users` + `profiles` |
| 2 | Write kudo: recipient (by department), title (danh hiệu = free title), message, hashtags | `kudos(recipient_id,title,message)` + `kudo_hashtags` + recipient's `profiles.department_id` |
| 3 | ❤️ a kudo, 1 per user, can un-heart | `kudo_reactions` unique(kudo_id,profile_id), DELETE allowed |
| 4 | See total kudos received / sent | `v_profile_stats.kudos_received / kudos_sent` |
| 5 | Hero tier from distinct senders (Rules screen) | `hero_tiers` + `v_user_hero_tier` |
| 6 | Every 5 ❤️ received → 1 secret-box spin → random 1 of 6 icons | `secret_boxes` + `open_secret_box()` RPC + trigger on `kudo_reactions` |
| 7 | Collect all 6 icons → mystery gift | `user_value_icons` + trigger → `user_rewards('icon_collection')` |
| 8 | Top-5 most-❤️ kudos → mystery gift | `v_national_kudos` + `grant_national_kudos()` → `user_rewards('national_kudos')` |

---

## 1. Entity map (model/screen → table)

| Source (Swift) | Table(s) |
|---|---|
| `User` / Profile / `searchSunners` | `profiles`, `departments` |
| `Award`,`AwardType`, Awards/Home, `awards`(exists) | `awards`, `award_criteria`, `award_recipients` |
| `Kudo`/`SendKudoPayload`, Kudos board/Send/View/All | `kudos`, `kudo_hashtags`, `hashtags`, `kudo_reactions`, `kudo_comments` |
| `SunValueIcon` + Profile icons + Rules | `value_icons`, `user_value_icons` |
| `SecretBox`/`Gift` + Secret Box screen | `secret_boxes` |
| Mystery gifts (icon-collection, national-kudos) | `rewards`, `user_rewards` |
| Rules Hero tiers → `User.level` | `hero_tiers` (+ `v_user_hero_tier`) |
| `ContentSection`/`CommunityStandard`/`Rule` | `content_documents`, `content_sections` |
| `AppNotification` / Notifications | `notifications` |
| `ProfileStatsData` | `v_profile_stats` |

---

## 2. DDL

### 2.1 Identity & org
```sql
create table public.departments (
    id   text primary key,              -- 'cevc3'
    name text not null                  -- 'CEVC3'
);

create table public.profiles (
    id            uuid primary key references auth.users(id) on delete cascade,
    full_name     text not null,
    avatar_url    text,
    department_id text references public.departments(id),
    role          text,
    created_at    timestamptz not null default now(),
    updated_at    timestamptz not null default now()
);
-- User.level (Hero tier) → v_user_hero_tier (derived). awardTypes → award_recipients.
-- collectedValueIcons → user_value_icons.
```

### 2.2 Awards (extends existing `public.awards`)
```sql
-- public.awards exists: id text pk, name, description, thumbnail_name, display_order, created_at.

create table public.award_criteria (
    id            uuid primary key default gen_random_uuid(),
    award_id      text not null references public.awards(id) on delete cascade,
    line_text     text not null,
    display_order int  not null default 0
);

create table public.award_recipients (
    id         uuid primary key default gen_random_uuid(),
    award_id   text not null references public.awards(id) on delete cascade,
    profile_id uuid not null references public.profiles(id) on delete cascade,
    year       int  not null default 2025,
    created_at timestamptz not null default now(),
    unique (award_id, profile_id, year)
);
```

### 2.3 Kudos  (req 2, 3)
```sql
create table public.hashtags (
    id         text primary key,        -- 'dedicated'
    name       text not null,           -- '#Dedicated'
    "group"    text,
    created_at timestamptz not null default now()
);

create table public.kudos (
    id           uuid primary key default gen_random_uuid(),
    sender_id    uuid references public.profiles(id) on delete set null,
    recipient_id uuid not null references public.profiles(id) on delete cascade, -- single recipient
    title        text,                  -- danh hiệu (tiêu đề tự đặt), e.g. 'IDOL GIỚI TRẺ'
    message      text not null,
    is_anonymous boolean not null default false,
    is_spam      boolean not null default false,
    created_at   timestamptz not null default now()
);
create index on public.kudos (created_at desc);
create index on public.kudos (sender_id);
create index on public.kudos (recipient_id);
-- One kudo = one recipient (matches SendKudoPayload.recipient). The recipient's
-- profiles.department_id provides the "phân biệt theo phòng ban".

create table public.kudo_hashtags (
    kudo_id    uuid not null references public.kudos(id) on delete cascade,
    hashtag_id text not null references public.hashtags(id) on delete cascade,
    primary key (kudo_id, hashtag_id)
);

create table public.kudo_reactions (           -- ❤️ — 1 per user, removable (req 3)
    id         uuid primary key default gen_random_uuid(),
    kudo_id    uuid not null references public.kudos(id) on delete cascade,
    profile_id uuid not null references public.profiles(id) on delete cascade,
    created_at timestamptz not null default now(),
    unique (kudo_id, profile_id)
);
create index on public.kudo_reactions (kudo_id);

create table public.kudo_comments (
    id         uuid primary key default gen_random_uuid(),
    kudo_id    uuid not null references public.kudos(id) on delete cascade,
    author_id  uuid not null references public.profiles(id) on delete cascade,
    text       text not null,
    created_at timestamptz not null default now()
);
```

### 2.4 Gamification — icons, secret boxes, hero tiers, rewards  (req 5, 6, 7, 8)
```sql
create table public.value_icons (              -- the 6 Sun* icons (SunValueIcon)
    id            text primary key,            -- 'revival','touch_of_light',...
    label         text not null,               -- 'REVIVAL'
    image_name    text not null,               -- 'rules_icon_revival'
    display_order int  not null default 0
);

create table public.user_value_icons (         -- collection per user (req 6/7)
    profile_id    uuid not null references public.profiles(id) on delete cascade,
    value_icon_id text not null references public.value_icons(id) on delete cascade,
    earned_at     timestamptz not null default now(),
    primary key (profile_id, value_icon_id)     -- set semantics; duplicates collapse
);

create type secret_box_state as enum ('closed','opening','standby','opened');

create table public.secret_boxes (              -- 1 spin granted per 5 ❤️ received (req 6)
    id                   uuid primary key default gen_random_uuid(),
    profile_id           uuid not null references public.profiles(id) on delete cascade,
    state                secret_box_state not null default 'closed',
    reward_value_icon_id text references public.value_icons(id),
    created_at           timestamptz not null default now(),
    opened_at            timestamptz
);
create index on public.secret_boxes (profile_id, state);

create table public.hero_tiers (               -- New/Rising/Super/Legend (Rules content, req 5)
    id            text primary key,            -- 'new','rising','super','legend'
    label         text not null,               -- 'New Hero'
    min_senders   int  not null,               -- 1, 5, 10, 21
    max_senders   int,                          -- 4, 9, 20, null(=∞)
    description   text not null,
    display_order int  not null default 0
);

create table public.rewards (                  -- mystery gifts (req 7, 8)
    id          text primary key,              -- 'icon_collection','national_kudos'
    title       text not null,
    description text
);

create table public.user_rewards (            -- granted gifts
    id         uuid primary key default gen_random_uuid(),
    profile_id uuid not null references public.profiles(id) on delete cascade,
    reward_id  text not null references public.rewards(id) on delete cascade,
    kudo_id    uuid references public.kudos(id) on delete set null,  -- set for national_kudos
    granted_at timestamptz not null default now(),
    unique (profile_id, reward_id, kudo_id)
);
```
> Hero tiers are keyed on **distinct senders** (`min_senders`/`max_senders`) — matches the
> Rules screen wording "Có N người gửi Kudos cho bạn".

### 2.5 Content (Community Standards + Rules text)
```sql
create table public.content_documents (
    id         text primary key,              -- 'community_standards','rules'
    title      text not null,                 -- 'Tiêu chuẩn chung','Thể lệ'
    updated_at timestamptz not null default now()
);

create table public.content_sections (        -- maps ContentSection (structured fields)
    id             uuid primary key default gen_random_uuid(),
    document_id    text not null references public.content_documents(id) on delete cascade,
    title          text not null,
    lead_paragraph text,
    body           text[]  not null default '{}',
    numbered_items text[]  not null default '{}',
    bullet_items   text[]  not null default '{}',
    highlight      text,
    display_order  int     not null default 0
);
```
> Rules = `rules` doc text + `hero_tiers` + `value_icons` (composed; not duplicated as text).

### 2.6 Notifications
```sql
create type notification_kind as enum ('kudo_received','kudo_reaction','award_granted','reward_granted','system');

create table public.notifications (
    id              uuid primary key default gen_random_uuid(),
    recipient_id    uuid not null references public.profiles(id) on delete cascade,
    kind            notification_kind not null,
    actor_id        uuid references public.profiles(id) on delete set null,
    message         text not null,
    related_kudo_id uuid references public.kudos(id) on delete cascade,
    is_read         boolean not null default false,
    created_at      timestamptz not null default now()
);
create index on public.notifications (recipient_id, is_read);
```

---

## 3. Derived views & functions

```sql
-- Anonymity invariant at DB layer (mirrors Kudo.resolvedSender). Client reads THIS, not raw kudos.
create view public.kudos_public as
select k.id, k.recipient_id, k.title, k.message, k.is_anonymous, k.is_spam, k.created_at,
       case when k.is_anonymous then null else k.sender_id end as sender_id,
       (select count(*) from public.kudo_reactions r where r.kudo_id = k.id) as reaction_count
from public.kudos k;

-- Profile stats (req 4) — ProfileStatsData.
create view public.v_profile_stats as
select p.id as profile_id,
  (select count(*) from public.kudos k where k.recipient_id = p.id) as kudos_received,
  (select count(*) from public.kudos k where k.sender_id    = p.id) as kudos_sent,
  -- hearts received = ❤️ on the user's SENT kudos (these drive secret boxes, req 6)
  (select count(*) from public.kudo_reactions r
     join public.kudos k on k.id = r.kudo_id where k.sender_id = p.id) as hearts_received,
  (select count(*) from public.secret_boxes b where b.profile_id = p.id and b.state =  'opened') as secret_box_opened,
  (select count(*) from public.secret_boxes b where b.profile_id = p.id and b.state <> 'opened') as secret_box_unopened
from public.profiles p;

-- Hero tier (req 5) — by number of DISTINCT senders (Rules: "Có N người gửi").
create view public.v_user_hero_tier as
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
create view public.v_national_kudos as
select * from public.kudos_public order by reaction_count desc, created_at asc limit 5;
```

---

## 4. RLS summary

| Table | SELECT | Writes |
|---|---|---|
| departments, awards, award_criteria, hashtags, value_icons, hero_tiers, rewards, content_documents, content_sections | `anon`+`authenticated` | `service_role` |
| profiles | `authenticated` (directory/search) | UPDATE own (`auth.uid()=id`); INSERT via signup trigger |
| award_recipients, user_rewards | `authenticated` (own for user_rewards) | `service_role`/trigger |
| kudos / kudo_hashtags | `authenticated` via `kudos_public` | INSERT where `sender_id=auth.uid()`; no user UPDATE/DELETE |
| kudo_reactions | `authenticated` | INSERT/DELETE own (`profile_id=auth.uid()`) — un-heart (req 3) |
| kudo_comments | `authenticated` | INSERT/UPDATE/DELETE own |
| user_value_icons, secret_boxes | own (`profile_id=auth.uid()`) | `service_role`/RPC/trigger |
| notifications | own (`recipient_id=auth.uid()`) | UPDATE own (mark read); INSERT trigger |

Raw `kudos` is not client-readable; clients use `kudos_public` (sender nulled when anonymous; can filter `is_spam`).

---

## 5. Automation (business rules)

- **Secret box grant (req 6)** — trigger `after insert/delete on kudo_reactions`: recompute the recipient-sender's total received hearts `H` (❤️ on their sent kudos); ensure `floor(H/5)` boxes exist for them (insert new `closed` boxes for the delta; never revoke on un-heart).
- **Open box (req 6)** — RPC `open_secret_box(p_box_id)` (SECURITY DEFINER, `authenticated` only; EXECUTE revoked from public/anon via migration 20260601001200): sets `state='opened'`, picks a **random value_icon the user does NOT yet own** (if all owned → no new icon), upserts `user_value_icons`, sets `reward_value_icon_id`, returns `won_value_icon`. Client calls this RPC and reads the returned icon — never writes `user_value_icons` directly.
- **Icon-collection gift (req 7)** — trigger `after insert on user_value_icons`: if the user now owns all 6 → insert `user_rewards('icon_collection')` (unique-guarded) + a `reward_granted` notification.
- **National-kudos gift (req 8)** — function `grant_national_kudos()` (SECURITY DEFINER): takes `v_national_kudos`, inserts `user_rewards('national_kudos', kudo_id)` for each kudo's sender. Run at program close (not real-time). **EXECUTE revoked from public/anon/authenticated** (migration 20260601001200) — not client-callable; must be invoked via `service_role` or a scheduled Edge Function.
- **Hero tier (req 5)** — live via `v_user_hero_tier` (no storage).
- **Notifications** — triggers: `kudos` insert → recipient `kudo_received`; `kudo_reactions` insert → sender `kudo_reaction`; `award_recipients`/`user_rewards` insert → `award_granted`/`reward_granted`.

---

## 6. Service → query mapping

| Swift service method | Query |
|---|---|
| `AuthService.signInWithGoogle` | `auth.signInWithOAuth(.google)` |
| `UserService.fetchCurrentUser / fetchUser(id)` | `profiles` (+ dept, `v_user_hero_tier`, `user_value_icons`) |
| `UserService.fetchProfileStats(userId)` | `v_profile_stats` |
| `UserService.searchSunners(query)` | `profiles` ILIKE full_name/department |
| `UserService.listDepartments` | `departments` |
| `KudoService.listKudos(filter)` | `kudos_public` (+ hashtag/dept filter) |
| `KudoService.listAllKudos(page)` | `kudos_public` order created_at desc, range pagination |
| `KudoService.viewKudo(id)` | `kudos_public` + `kudo_comments` |
| `KudoService.sendKudo(payload)` | insert `kudos`(recipient_id,title,message) + `kudo_hashtags` |
| `KudoService.listHashtags` | `hashtags` |
| (heart / un-heart) | insert / delete `kudo_reactions` |
| `AwardService.fetchAwards(userId)` | `award_recipients` ⨝ `awards` |
| `AwardService.awardDetail(type)` | `awards` + `award_criteria` |
| `AwardsService.fetchAwards` (Home) | `awards` order display_order |
| `ContentService.communityStandards` | `content_sections` where doc='community_standards' |
| `ContentService.rules` | `content_documents`='rules' + `hero_tiers` + `value_icons` |
| `NotificationService.*` | `notifications` (list / mark read / unread count) |
| `SecretBoxService.currentBox` | `GET /rest/v1/secret_boxes?state=eq.closed&profile_id=eq.{uid}` — returns unopened count |
| `SecretBoxService.openBox(id:)` | RPC `open_secret_box(p_box_id)` (`authenticated`; EXECUTE revoked from public/anon) → returns `won_value_icon`; DB upserts `user_value_icons` |

---

## 7. Seed data
- `departments`: CEVC3, CEVC5, CEVC7, CEVC10, …
- `hashtags`: #Dedicated, #Inspiring, … (+ group)
- `value_icons`: 6 from `SunValueIcon`
- `hero_tiers`: new(1–4) / rising(5–9) / super(10–20) / legend(21–∞) + descriptions (Rules)
- `rewards`: `icon_collection`, `national_kudos`
- `awards`: existing 3 + mvp / signature-creator / top-project-leader / best-manager; `award_criteria`
- `content_documents`+`content_sections`: Community Standards (`figmaSample`) + Rules text

---

## 8. Open questions / assumptions

1. **Hero tier metric (req 5)** — RESOLVED: **distinct senders** (`count(distinct sender_id)`), matching the Rules screen wording "Có N người gửi Kudos cho bạn".
2. **Secret box on un-heart** — boxes are granted on reaching each 5-❤️ milestone and **not revoked** if a heart is later removed (standard gamification). Confirm acceptable.
3. **Spin reward pool** — picks a random icon **not yet owned** so the set always progresses toward 6; once all owned, a spin yields no new icon. Alternative: allow duplicates.
4. **National-kudos recipient (req 8)** — gift granted to each top-5 kudo's **sender** (author). Confirm (vs. recipient).
5. **Spam (`is_spam`)** — stored flag; the 10 Community-Standards criteria imply a moderation job/Edge Function (out of schema scope).
6. **`AwardType` enum (6) vs `awards` rows (3)** — `awards.id` slugs are canonical; seed must add the 4 missing award rows.
