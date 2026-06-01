# Project Changelog

## [Unreleased] — 2026-06-01

### Added — Secret Box live + gamification security hardening (Increment 2 Batch 6)

- **`SecretBoxService.currentBox()`** — live; `GET /rest/v1/secret_boxes` filtered to `state=closed` + authenticated user; returns unopened count displayed in UI
- **`SecretBoxService.openBox(id:)`** — live; calls `open_secret_box(p_box_id)` Postgres RPC (SECURITY DEFINER, `authenticated`); RPC sets `state='opened'`, picks a random value icon not yet owned by the user, upserts `user_value_icons`, returns `won_value_icon`; client never mutates `user_value_icons` directly
- **UI** — Secret Box screen shows real unopened count; opens box and reveals won icon from RPC response
- **DB migration `20260601001200`** — EXECUTE hardening: revoked on `grant_national_kudos` (public/anon/authenticated — function no longer client-callable; privilege-escalation path closed), `open_secret_box` (public/anon; authenticated kept), and 6 trigger/helper functions (public/anon/authenticated). Closes the systemic Supabase default-privilege gap flagged since Batch 1 (`grant_national_kudos` was previously PUBLIC-callable).
- **Dev seed** — 5 closed secret boxes added for `sunner@sun.com` test account
- Build: SUCCEEDED · Security: privilege-escalation vector on `grant_national_kudos` closed

### Added — Kudo interaction: react/unreact + viewKudo + comments (Increment 2 Batch 5)

- **DB migration** — `view_kudo(p_id uuid)` Postgres RPC (SECURITY DEFINER, `authenticated`): returns one kudo JSON + its comments array via shared `kudo_json` helper
- **DB migration** — `list_kudos` RPC extended: now returns `has_reacted` boolean (true if `auth.uid()` has a row in `kudo_reactions` for that kudo)
- **DB migration** — `kudo_json(uuid)` internal SQL helper (SECURITY DEFINER): single source of truth for kudo JSON composition from `kudos_public`; EXECUTE revoked from public/anon/authenticated — called only by `list_kudos` / `view_kudo`, not a callable RPC endpoint
- **REST surface** — `POST /rest/v1/kudo_reactions` (react); `DELETE /rest/v1/kudo_reactions?kudo_id=eq.{id}&profile_id=eq.{id}` (unreact)
- `SupabaseRESTClient` — added `delete(_:query:)` method; guards against empty/unfiltered query to prevent accidental full-table deletes
- `Kudo.hasReacted: Bool` — new model field decoded from `has_reacted` in `list_kudos` / `view_kudo` RPC response
- `KudoService.viewKudo(id:)` — now live; calls `view_kudo` RPC; decodes kudo + comments
- `KudoService.react(kudoId:)` / `unreact(kudoId:)` — live; POST / DELETE to `kudo_reactions` REST endpoint
- `KudosBoardViewModel` + `ViewKudoViewModel` — optimistic react/unreact toggle; in-flight guard (prevents double-tap); rollback on error
- `KudosBoardView` — ❤️ button on `KudoCard` is tappable and reflects `hasReacted` state
- `ViewKudoView` / `ViewKudoContainer` — kudo detail screen now shows comments (read-only); comment submission deferred
- Seed: added sample `kudo_comment` row
- Build: SUCCEEDED · Review: DONE · End-to-end: react/unreact toggled via curl + UI; kudo detail renders real comments
- **Known follow-ups:** comment submission (`KudoService.addComment`); `spotlightTotalKudos` / `fetchPersonalStats` / `listGiftRecipients` remain stubbed; `SecretBoxService`; `NotificationService`

### Added — Kudos WRITE + Search/Hashtags API wired to live DB (Increment 2 Batch 4)

- `SupabaseRESTClient` — added `insert(endpoint, payload)` method (POST /rest/v1/<table>, return=minimal to avoid payload bloat)
- `KudoService.sendKudo(title, message, recipientId, hashtags, senderAnon)` — inserts kudos row + maps `kudo_hashtags` junction table entries; sender set to `auth.uid`; return minimal for perf
- `KudoService.listHashtags()` — live select from `hashtags` table
- `UserService.fetchUser(userId)` — calls `get_profile(userId)` RPC (returns composed profile JSON: name/dept/icons/stats); removed dead mock directory
- `UserService.searchSunners(query)` — `ilike` profile search + department name embed; live DB verified
- `SendKudoViewModel` — currentUserId now optional (fixes compile error); self-send guard enforced; real sendKudo flow wired
- `FeatureFlags.useMockKudoData = false` — flips to live Send-Kudo flow (compose → send inserts real kudo)
- Build: SUCCEEDED · Review: 0-critical (H1/M1 fixes applied) · End-to-end: SendKudoContainer compose + submit inserts kudo (appears on feed); SearchSunnerContainer shows real users; ProfileOtherContainer shows real other-profile data (curl + Kudos board screenshot verified)
- **Known follow-ups (still mock/flagged):** KudoService.viewKudo (detail + comments tapping real kudo errors notFound); react/unreact heart UI; SecretBoxService.currentBox/openBox; NotificationService.listNotifications/markRead; Board hashtag/dept filter UI wiring (RPC param present, ignored); Kudo.title not rendered in KudoCard (P6 UI); non-transactional sendKudo path (kudo saved even if hashtag insert fails) — consider perform_send_kudo RPC before prod

### Added — Kudos READ API (board + all + profile received) wired to live DB (Increment 2 Batch 3)

- `supabase/migrations/20260601000900_list_kudos_rpc.sql` + `20260601001000_refactor_kudos_read.sql` — `list_kudos(p_limit, p_offset, p_recipient, p_sender)` RPC reads from `kudos_public` view (anonymity single-source), page-size capped, optional recipient/sender filter for board/profile filtering
- `KudoService` — DTO decode layer for Kudos; `listAllKudos(page)` + `listKudos()` (board feed) + `listReceivedKudos(userId)` now query live `list_kudos` RPC (removed dead mockFeed)
- `ProfileViewModel` — kudos property now reads user's RECEIVED kudos (not global feed); received/sent counts from live `v_kudos_stats` view (fixed regression from batch 2)
- Dev seed: buddy user + 5 kudos (1 anonymous, 1 spam) + hashtags + reactions; `supabase db reset` pass
- Build: SUCCEEDED · Review: 7/10 0-critical (H1/H2/L3 fixes applied) · End-to-end: Kudos board + All Kudos + Profile kudos section render real DB data (anonymity, hashtags, hearts, dates verified; curl + Kudos board screenshot)
- **Known follow-ups (still mock/deferred):** KudoService.viewKudo/sendKudo/react/unreact, listHashtags, spotlight/personalStats/giftRecipients; SecretBoxService; NotificationService; UserService.fetchUser/searchSunners; board hashtag/department filters (server-side RPC filter present, UI wiring skipped); Kudo.title rendering in KudoCard (P6 UI); pre-prod items (JWT refresh/expiry, revoke PUBLIC EXECUTE, SendKudo self-send guard, dev creds #if DEBUG)

### Added — Supabase Auth (local email/password) + self-Profile wiring (Increment 2 Batch 2)

- `AuthService` — real login via GoTrue REST (email/password sign-in), JWT storage + session restore + sign-out; sets JWT on SupabaseRESTClient for authenticated RPC/REST calls
- `SupabaseRESTClient` — added `callRPC(endpoint, payload)` method for POST /rpc requests (e.g., `get_profile(user_id)`)
- `UserService` — wired `fetchCurrentUser()` (calls `get_profile(uid)` RPC) and `fetchProfileStats(userId)` (queries `v_profile_stats` view); both now read live DB
- `LoginContainerView` — removed dev-bypass, now calls real `signIn(email, password)` on Google button tap; on success, sets `isAuthenticated` → navigates to Home
- `ProfileDTO` — removed dead stats/toStats methods (consolidated into ProfileStatsData)
- `seeds/dev/00_dev_users.sql` — seeded test user `sunner@sun.com` / `Password123!` with department and 3 collected value icons; `config.toml` `sql_paths` enabled
- Build: SUCCEEDED · Review: 0-critical (4 fixes applied) · End-to-end: login → Profile displays real name/department/icons/stats from DB (verified via curl + in-app screenshot)
- **Known follow-ups (pre-prod gates):** JWT expiry/refresh (H1), SendKudoViewModel currentUserId binding (M3), revoke PUBLIC EXECUTE on Postgres functions (security hardening)

### Added — Supabase API groundwork: get_profile RPC + model/DTO alignment (Increment 2 Batch 1, auth-independent)

- `supabase/migrations/20260601000800_get_profile_rpc.sql` — `get_profile(p_id uuid)` RPC (SECURITY DEFINER) returns composed JSON: profile user data + department name + hero tier label + collected value icon IDs + stats (kudos received/sent, hearts, secret box counts); grant to `authenticated` only (PUBLIC EXECUTE revoked for security)
- `Models/SunValueIcon.swift` — added `dbId` property + `init?(dbId:)` for bidirectional DB slug ↔ enum case mapping (`'touch_of_light'` ↔ `.touchOfLight`)
- `Models/Kudo.swift` — added `title: String?` field (optional danh hiệu/heading); anonymity invariant enforced in `init(from:)`
- `Services/ProfileDTO.swift` — decode layer for `get_profile` RPC JSON payload with `.convertFromSnakeCase` via `SupabaseRESTClient`; maps to domain `User` (with `level` = hero_label, icons decoded via `SunValueIcon`) + `ProfileStatsData`
- RPC verified end-to-end (DB migration applies, sample profile returns correct JSON structure)
- Build: SUCCEEDED · Review: 0 critical (2 fixes applied)
- **Blocked follow-ups (logged, not implemented):** (a) `SupabaseRESTClient.post(rpc:)` method needed before P5 wiring; (b) RPC NULL → `UserError.notFound` mapping in service layer; (c) SECURITY: `grant_national_kudos` function (SECURITY DEFINER, writes `user_rewards`) currently PUBLIC-callable — revoke during P2 hardening (migration 20260601000700)

### Added — Supabase REST client + ContentService (Increment 1 of API integration)

- `Services/SupabaseRESTClient.swift` — reusable actor-based PostgREST client (GET + headers + `convertFromSnakeCase` decode + typed error enum); pattern extracted from `AwardsService` for DRY across all data services
- `Services/ContentService.swift` — `communityStandards()` + `rules()` wired to read live `content_sections` table from local Supabase instance (anon key, no auth required)
- Build: SUCCEEDED · Code review: 8/10, 0-critical (2 fixes applied) · Integration: live-DB read end-to-end verified (Community Standards screen renders values written directly into DB)
- **Increment 1 scope:** REST client + public-read Content only (no SDK yet, no RPC, no auth). Deferred to Increment 2: Supabase Swift SDK, Google OAuth, KudoService/AwardService wiring, user-context services, all integration & verification.

### Added — Notifications screen: mock data + UI refinement

- `FeatureFlags` — new `useMockNotifications: Bool` (default `true`); when true, `NotificationsViewModel` loads 7 mock notifications (one per `AppNotification.Kind`) and mark-read is local-only; real `NotificationService` path preserved in the `else` branch (3rd `useMock*` flag after `useMockAwards`, `useMockKudoData`)
- `AppNotification.Kind` expanded 4 → 7: added `kudoReaction`, `secretBox`, `levelUp`, `contentHidden`, `badgeCollected`, `reviewRequest`; each kind has a distinct icon/color
- `NotificationsView` refactored to `safeAreaInset(.top)` + background-keyvisual + `toolbar(.hidden)` scroll pattern (same as `CommunityStandardsView` / `RulesView`); the `.ignoresSafeArea(.top)` anti-pattern removed
- Tap → mark read (`TC_NOTIF_FUN_001`), mark-all-read button (`FUN_002`), `contentHidden` inline link navigates to Community Standards
- **Known follow-ups:** per-type deep navigation (e.g. open kudo from notification) deferred until API wiring

### Added — Community Standards screen: mock content + UI refinement

- `ContentSection` — added optional `leadParagraph`, `numberedItems`, `bulletItems`, `highlight` fields (all defaulted; backward-compatible with existing Rules rendering)
- `CommunityStandardsSectionView` — renders structured sections with gold-bold title → lead paragraph → body → numbered list (1–10, hanging indent) → bullet points → gold-bold contact highlight
- `CommunityStandard.figmaSample` — populated with full design content (2 sections: "Tiêu chuẩn cộng đồng" with 10 spam criteria + "Tiêu chuẩn bảo mật" with 2 security bullets + contact info)
- `ContentService.communityStandards()` — returns `CommunityStandard.figmaSample` (mock; `// TODO: Supabase` deferred)
- Build: `xcodebuild build` → SUCCEEDED; Code review: 8/10, 0 critical issues; Visual validation: simulator screenshot verified against MoMorph design
- **Known follow-ups (pre-existing / future):** (a) container double error-UI pattern (ContainerErrorView + .alert) shared across containers; (b) `ContentSection.decodeIfPresent` when Supabase JSON path wired

### Added — Send/Write Kudo screen logic (mock data path)

- `FeatureFlags` — new `useMockKudoData: Bool` (default `true`); when true, `SendKudoViewModel` loads mock recipients/hashtags/current-user and simulates submit; real `KudoService`/`UserService` path is preserved in the `else` branch
- `SendKudoMockData.swift` (`Views/Kudos/`) — bundled mock recipients, hashtags, current-user
- `KudoService.SendKudoPayload` — added `title` field
- `SendKudoViewModel` — title wiring, self-send guard (spec B.2), max-5-hashtags cap, full validation (recipient + title + message + ≥1 hashtag), simulated submit success; rich-text toolbar / @mention / image-upload remain visual-only
- `SendKudoContainer` — cancel-confirm dialog (spec H), "Community Standards" link wired (spec B.5), success toast + pop navigation on submit (TC_WRITE_FUN_001)

### Added — Kudos board UI completion (Sun*Kudos screen)

**New UI sections (MoMorph fO0Kt19sZZ)**
- `SpotlightBoardSection` — SPOTLIGHT BOARD header with 388 Kudos stat, static chart image (`SpotlightChart` asset), non-functional search bar
- `KudosStatsBlock` — personal ALL KUDOS stats: Số Kudos nhận/gửi, Số tim + x2-fire badge (`X2FireBadge` asset), Secret Box opened/unopened counts; "Mở Secret Box" button disabled when unopened=0, wired to Secret Box flow via `AppRouter`
- `GiftRecipientsList` — "10 SUNNER NHẬN QUÀ MỚI NHẤT" list of Top-10 gift recipients

**New models**
- `KudosStats` — personal kudos statistics (received, sent, hearts, secret box counts)
- `GiftRecipient` — Top-10 gift recipient entry

**Mock data layer**
- `KudoService+Mock.swift` — service extension providing mock `KudosStats` and `GiftRecipient` data; stub bodies return mock values; swap to real Supabase API is surgical (pending SDK wiring)
- `UserService.mockDepartments` — department mock data added

**Files edited:** `KudoService.swift`, `UserService.swift`, `KudosBoardViewModel.swift`, `KudosBoardView.swift`, `KudosAllSection.swift`, `KudosBoardContainer.swift`

**Interactions not yet wired:** Spotlight search, Top-10 tap, heart button (visual-only this pass)

---

### Changed — Home screen logic wired to develop3 architecture

- `FeatureFlags` — added `useMockAwards` flag (default `true`) + `eventYear/Month/Day` countdown date constants (demo 2026-06-28; real event 2025-12-26)
- `CountdownTimer` — target date sourced from `FeatureFlags` (was hardcoded)
- `AwardType` — new `init(awardId:)` mapping backend award IDs → `AwardType` (`top-manager` → `.bestManager` fallback)
- `HomeViewModel` — 8 interactive CTAs now push real `NavDestination` via `AppRouter` (Search → `.searchSunner`, Bell → `.notifications`, About Award → `.awardDetail(.topTalent)`, About Kudos → `.kudosBoard`, Award card → `.awardDetail`, Kudos detail → `.kudosBoard`, FAB pencil → `.sendKudo`, FAB S/Kudos → `.allKudos`); `ToastCenter` dependency removed from `HomeViewModel`
- `HomeViewModel` — awards now load from `HomeViewMockData` when `FeatureFlags.useMockAwards` is true; live Supabase REST path preserved in the `else` branch
- `HomeContainerView` — passes `AppRouter` into nav closures

---

## [Unreleased] — 2026-05-30

### Added — Track B backbone (iOS Sun* Kudos app)

**Navigation**
- `AppRouter` with `AppRoute`, `AppErrorKind`, `NavDestination` enums; push/pop/popToRoot
- `MainTabView` shell
- `TopNavigationBar` shared component

**Models** (10)
- `User`, `Department`, `Hashtag`, `Award`, `AwardType`
- `Kudo` (anonymity enforced), `KudoComment`
- `AppNotification`
- `SecretBox`, `Gift`
- `ContentSection`, `CommunityStandard`, `Rule`

**Services** (6, stubbed Supabase, typed `LocalizedError` enums)
- `AuthService`, `UserService`, `KudoService`, `AwardService`, `NotificationService`, `SecretBoxService`, `ContentService`

**ViewModels** (10, `@Observable @MainActor`)
- `LoginViewModel`, `KudosBoardViewModel`, `AllKudosViewModel`, `ViewKudoViewModel`, `SendKudoViewModel`
- `SearchSunnerViewModel`, `ProfileViewModel`, `AwardsViewModel`, `NotificationsViewModel`, `SecretBoxViewModel`, `ContentViewModel`

### Added — Track A: UI screens (complete, all 14 MoMorph iOS screens)

**Feature clusters implemented as presentational SwiftUI views (no direct service calls):**
- **Error pages (phase 05):** `ErrorView` + `AccessDeniedView` / `NotFoundView` wrappers (403/404)
- **Language picker (phase 06):** `LanguagePickerView` thin wrapper over existing `LanguageDropdownView`
- **Notifications (phase 07):** `NotificationsView` with read/unread list
- **Profile — self (phase 08):** `ProfileSelfView` with awards, kudos, badges
- **Profile — other (phase 09):** `ProfileOtherView`
- **Award detail (phase 10):** `AwardDetailView`
- **Secret Box (phase 11):** `SecretBoxView`
- **Kudos board (phase 12):** `KudosBoardView`
- **All kudos (phase 13):** `AllKudosView` with filter
- **Send kudo (phase 14):** `SendKudoView`
- **View kudo (phase 15):** `ViewKudoView`
- **Search Sunner (phase 16):** `SearchSunnerView`
- **Community Standards (phase 17):** `CommunityStandardsView`
- **Rules (phase 18):** `RulesView`

**Reusable components introduced:**
- `KudoCard`, `FilterOverlay`, profile sub-views (`ProfileHeaderView`, `ProfileStatsView`, `ProfileTabsView`), `ProfileBadgeSlot`, `AwardVariantStyle`

### Added — Phase 19: Integration (iOS plan complete)

**Container layer** (`Views/Containers/`, 13 files)
- One `*Container` per screen: owns `@Observable` ViewModel via `@State`, maps VM state → presentational view props, dispatches actions, routes via `AppRouter`
- Containers: `KudosBoardContainer`, `AllKudosContainer`, `ViewKudoContainer`, `SendKudoContainer`, `SearchSunnerContainer`, `NotificationsContainer`, `ProfileSelfContainer`, `ProfileOtherContainer`, `AwardDetailContainer`, `SecretBoxContainer`, `CommunityStandardsContainer`, `RulesContainer`
- Shared `ContainerErrorView` for loading/empty/error states across all screens

**Navigation graph wired**
- `MainTabView` updated: tab roots use containers (`KudosBoardContainer`, `NotificationsContainer`, `ProfileSelfContainer`)
- `NavDestinationResolver` (private, in `MainTabView`) resolves all `NavDestination` cases to the correct container
- `ErrorView` route wired via `AppRoute.error(AppErrorKind)`

**ViewModel additions**
- `ProfileViewModel`: kudos count, awards count fields
- `SecretBoxView`: `onBack` callback added

**Plan status:** entire iOS Sun* Kudos app plan complete (Track B backbone + 14 Track A screens + phase 19 integration)

### Pending
- Supabase SDK wiring (all service methods currently stubbed; real data is future work)

---

## [Unreleased] — 2026-05-29

### Added — Home Screen (Phase 3)

**iOS**
- `HomeContainerView`, `HomeView` and sub-views: `HomeHeaderView`, `HomeHeroSection`, `HomeAwardsSection`, `HomeAwardCard`, `HomeKudosSection`, `HomeThemeSection`, `HomeBottomNavBar`, `HomeFAB`
- `HomeViewModel` (`@Observable`) — owns `AwardsLoadState` and drives awards fetch
- `AwardsService` — `URLSession` → Supabase REST `GET /rest/v1/awards?select=*&order=display_order.asc`
- `CountdownTimer` (`@Observable`) — 1-second tick toward 2025-12-26 00:00 Asia/Saigon; exposes `CountdownValue`, `comingSoonVisible`, `eventEnded`
- `ToastCenter` (`@Observable` singleton) + `ToastBannerView` — ephemeral overlay at app root, auto-dismisses after 1.6 s
- `HomeModels.swift` — `CountdownValue`, `AwardItem`, `HomeTab`
- `AwardsLoadState` enum — `idle / loading / loaded([AwardItem]) / empty / error(String)`
- `SupabaseConfig` — REST base URL (`http://localhost:54321`), anon key, `restURL` helper
- `FeatureFlags` — `isKudosAvailable: Bool` (compile-time, default `true`)

**Integration note (merge resolution)**
- Home is wired as the `.home` tab of the existing `MainTabView` shell (develop3 navigation architecture). The per-screen `HomeBottomNavBar` is superseded by the shared tab bar, so the standalone `.awards` / `.kudos` / `.profile` routes and their placeholder views are not part of the integrated navigation graph.

**Backend**
- Supabase migration `20260529000000_create_awards.sql` — `public.awards` table, RLS enabled, anon-read policy
- Seed `supabase/seeds/awards.sql` — 3 rows: Top Talent, Top Project, Top Manager

---

## [0.1.0] — 2026-05-28

### Added — Login Screen (Phase 2)

- `LoginView`, `LoginContainerView`, `LoginHeaderView`, `LoginGoogleButton`
- `LanguageDropdownView`, `AppLanguage` model
- `AuthService` — Google OAuth stub (Supabase Swift SDK not yet installed via SPM)
- `AppRouter` (`ObservableObject`) with `AppRoute.login` / `.home`
- `Color+Hex.swift` extension
- Initial Xcode project, MVVM + Router directory structure
