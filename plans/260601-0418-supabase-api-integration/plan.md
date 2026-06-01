# Plan — Supabase API Integration (chạy app hoàn chỉnh)

Thay toàn bộ stub service bằng lệnh gọi Supabase thật, để mọi chức năng trên màn hình chạy với DB thật (schema đã tạo + verify ở [docs/database-schema.md](../../docs/database-schema.md)).

**Bối cảnh:**
- Backend đã xong: 8 migrations + seeds, `supabase db reset` pass, local stack chạy ở `:54321`.
- `AwardsService` đã gọi Supabase qua REST (URLSession + PostgREST) — pattern tham chiếu.
- Còn lại các service đang stub (`return []` / `.sample` / `throw`).
- Login mới có **dev-bypass** (vào thẳng Home), chưa có session thật.

## Quyết định kiến trúc
- ~~Cài Supabase Swift SDK~~ → **THỰC TẾ ĐÃ ĐỔI:** dùng **raw REST** (`SupabaseRESTClient` actor: GET + `callRPC`) cho Database + **Auth email/password local** (GoTrue REST) — KHÔNG cài SDK. Lý do: chạy + verify ngay, không cần SDK/Google creds. Google OAuth thật = follow-up prod.
- Services bọc mọi call Supabase; **ViewModels/Views không import Supabase/networking** (theo `ios-development.md`).
- DTO `Decodable` (snake_case, `.convertFromSnakeCase`) → map sang domain model. Map id value-icon DB ↔ `SunValueIcon`.
- RPC tổng hợp khi shape phức tạp: `get_profile(p_id)` (profile gộp), `list_kudos(...)` (feed kudos, ẩn danh từ `kudos_public`).

## Phases

| # | Phase | File | Depends |
|---|-------|------|---------|
| 1 | Foundation: SDK + SupabaseClient + config + URL scheme + DTO base + RPC `get_profile` | [phase-01-foundation.md](phase-01-foundation.md) | — |
| 2 | Auth: Google OAuth thật + session restore/sign-out + router gate (bỏ dev-bypass) | [phase-02-auth.md](phase-02-auth.md) | P1 |
| 3 | Models/DTO alignment (Kudo +title/recipient, decoding, value-icon map) | [phase-03-models-dto.md](phase-03-models-dto.md) | P1 |
| 4 | Read-public services (Content, Award(s), Kudos list, departments/hashtags) | [phase-04-read-services.md](phase-04-read-services.md) | P1, P3 |
| 5 | User-context services (profile, sendKudo, reactions, secret box, notifications, search) | [phase-05-user-services.md](phase-05-user-services.md) | P2, P3 |
| 6 | UI/ViewModel wiring (heart/un-heart, send flow, open box) + integration & verify | [phase-06-integration-verify.md](phase-06-integration-verify.md) | P4, P5 |

**Song song được:** P3 ∥ P2 (sau P1). P4 ∥ P5 nhưng P4 không cần auth (làm trước thấy kết quả sớm); P5 cần P2.

## Phạm vi chạy được theo tiến độ
- Sau P1+P4: Kudos board, Tiêu chuẩn cộng đồng, Thể lệ, Awards hiển thị **data thật** (anon key, chưa cần login).
- Sau P2+P5: Login Google thật → Profile của tôi, gửi Kudo, thả tim, Secret Box, thông báo chạy đầy đủ (RLS theo user).

## Rủi ro / lưu ý
- `SupabaseConfig.anonKey` là JWT demo legacy; instance local in key kiểu mới (`sb_publishable_…`) — verify 1 request thật ở P1.
- URL scheme `com.mockprojectaidd://login-callback` phải đăng ký trong Xcode (Info → URL Types) cho OAuth.
- RLS: request thiếu session → chỉ đọc được bảng public; chức năng theo-user sẽ bị chặn nếu chưa login (đúng thiết kế).
- Heart/un-heart, kudo `title`/recipient đơn: cần bổ sung method + chỉnh model (P3/P5).

## Status

**Increment 2 Batch 4 (2026-06-01, Kudos WRITE + search/hashtags) — Build SUCCEEDED, Review 0-critical (H1/M1 fixes applied), end-to-end verified**

| Phase | Status | Notes |
|-------|--------|-------|
| P1 Foundation | **DONE** | `SupabaseRESTClient` (actor: GET + callRPC + insert w/ return=minimal) + RPCs `get_profile`/`list_kudos`. SDK KHÔNG dùng — thay bằng raw REST. |
| P2 Auth | **DONE** | AuthService: real local email/password sign-in (GoTrue REST) + session restore + sign-out; JWT set on SupabaseRESTClient. Google OAuth dev alias (test user seeded); real Google OAuth deferred to prod. |
| P3 Models/DTO | **DONE** | `SunValueIcon.dbId` + `init?(dbId:)`, `Kudo.title`, `ProfileDTO`, `KudoDTO` (recv/sender decode); full Kudo model alignment complete. |
| P4 Read services | **DONE** | ContentService + KudoService.listAllKudos/listKudos/listReceivedKudos wired to list_kudos RPC. Board, All Kudos, Profile received-kudos sections verified w/ real data. Hashtag/department filters present in RPC, UI wiring pending (P6). |
| P5 User services | **DONE (WRITE path)** | UserService: fetchCurrentUser (get_profile RPC) + fetchProfileStats + **fetchUser (get_profile)** + **searchSunners (ilike + dept embed)** wired; live DB verified. KudoService: **sendKudo (insert + kudo_hashtags)** + **listHashtags** wired live. FeatureFlags.useMockKudoData → false. React/unreact/viewKudo/SecretBox/Notification pending. |
| P6 Integration & verify | partial | P4 Kudos read ✓, P5 write ✓ (compose → send inserts real kudo, search → real users, other-profile → real data). viewKudo still mock (flag-flip reachable, errors notFound). React/unreact UI + SecretBox + Notifications + board filters pending. |

**Increment 2 Batch 1 (Auth-Independent) — COMPLETED:**
- ✅ `supabase/migrations/20260601000800_get_profile_rpc.sql` — `get_profile(p_id)` RPC (composed profile JSON: user + dept + hero tier + icons + stats), SECURITY DEFINER, grant to `authenticated` only (PUBLIC execute revoked)
- ✅ `Models/SunValueIcon.swift` — added `dbId` property + `init?(dbId:)` (DB slug ↔ case mapper)
- ✅ `Models/Kudo.swift` — added `title: String?` (optional danh hiệu/heading)
- ✅ `Services/ProfileDTO.swift` — decode layer for `get_profile` RPC JSON → `User` + `ProfileStatsData` (consumed in P5)
- ✅ Build: SUCCEEDED
- ✅ Review: 0 critical (2 fixes applied)
- ✅ `get_profile` RPC verified end-to-end

**Increment 2 Batch 4 (Kudos WRITE + search/hashtags) — COMPLETED:**
- ✅ `SupabaseRESTClient` — added `insert(endpoint, payload)` (POST /rest/v1/<table>, return=minimal to avoid echo bloat)
- ✅ `KudoService.sendKudo(title, message, recipientId, hashtags, senderAnon)` — inserts kudos + maps kudo_hashtags via junction (non-transactional, flag TODO compensating delete on error)
- ✅ `KudoService.listHashtags()` — live select from hashtags table
- ✅ `UserService.fetchUser(userId)` — calls get_profile RPC (returns real other-profile data); removed dead mock directory
- ✅ `UserService.searchSunners(query)` — ilike on profiles + department embed; live DB verified
- ✅ `SendKudoViewModel` — currentUserId → optional, self-send guard fixed, real sendKudo flow
- ✅ `FeatureFlags.useMockKudoData` → false (live Send-Kudo flow enabled)
- ✅ Build: SUCCEEDED
- ✅ Review: 0-critical (H1/M1 fixes applied)
- ✅ End-to-end: compose → send inserts real kudo (appears on board); search → real users; other-profile → real data (curl + Kudos board screenshot verified)
- **Still mock/flagged:** viewKudo (detail + comments); react/unreact; SecretBoxService; NotificationService
- **Non-transactional path:** sendKudo inserts kudo even if hashtag insert fails — consider perform_send_kudo RPC before prod

**Increment 2 Batch 3 (Kudos READ) — COMPLETED:**
- ✅ `supabase/migrations/20260601000900_list_kudos_rpc.sql` + `20260601001000_list_kudos_filters.sql` — `list_kudos(p_limit, p_offset, p_recipient, p_sender)` RPC composes kudos JSON from `kudos_public` view, page-size capped, optional recipient/sender filters for board + profile filtering
- ✅ `KudoService` — KudoDTO decode layer; `listAllKudos(page)` + `listKudos(board feed)` + `listReceivedKudos(userId)` wired to live `list_kudos` RPC (removed dead mockFeed)
- ✅ `ProfileViewModel` — kudos property now reads user's RECEIVED kudos (not global feed); received/sent counts from real `v_profile_stats` view (fixed regression)
- ✅ Dev seed — buddy user + 5 kudos (1 anon, 1 spam) + hashtags + reactions populated; `supabase db reset` pass
- ✅ Build: SUCCEEDED
- ✅ Review: 7/10 0-critical (H1/H2/L3 fixes applied)
- ✅ End-to-end: Kudos board + All Kudos + Profile kudos section show real DB data (anonymity, hashtags, hearts, dates all correct; curl + Kudos board screenshot verified)

**Follow-ups logged (still mock/deferred, do NOT implement now):**
- P5 rest: KudoService.viewKudo (detail), sendKudo, react/unreact, listHashtags, spotlight/personalStats/giftRecipients
- P5 rest: SecretBoxService, NotificationService, UserService.fetchUser/searchSunners
- Board hashtag/department FILTER ignored (server-side filter present in RPC, UI wiring skipped; requires hashtags/departments from DB)
- Kudo.title in model/DTO but KudoCard heading doesn't render it (P6 UI refinement)
- Pre-prod (carried): JWT refresh/expiry, revoke PUBLIC EXECUTE on migration-700 functions, SendKudo self-send guard, dev creds behind #if DEBUG

**Increment 2 Batch 2 (Auth + Self-Profile) — COMPLETED:**
- ✅ `AuthService` — local email/password sign-in (GoTrue REST) + JWT store/restore + sign-out; sets JWT on SupabaseRESTClient
- ✅ `SupabaseRESTClient` — added `callRPC(endpoint, payload)` (POST /rpc) + shared send logic
- ✅ `UserService` — fetchCurrentUser (get_profile RPC) + fetchProfileStats (v_profile_stats) wired; live DB verified
- ✅ `LoginContainerView` — removed dev-bypass, now calls real `signIn(email, password)`
- ✅ `ProfileDTO` — removed dead stats/toStats (consolidated in ProfileStatsData)
- ✅ Dev seed — `seeds/dev/00_dev_users.sql` with test user (sunner@sun.com / Password123!) + dept + 3 value icons
- ✅ Build: SUCCEEDED
- ✅ Review: 0 critical (4 fixes applied)
- ✅ End-to-end: login → Profile shows real name/dept/icons/stats from DB (curl + in-app screenshot verified)
