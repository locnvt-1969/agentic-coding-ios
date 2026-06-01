# Plan — Supabase API Integration (chạy app hoàn chỉnh)

Thay toàn bộ stub service bằng lệnh gọi Supabase thật, để mọi chức năng trên màn hình chạy với DB thật (schema đã tạo + verify ở [docs/database-schema.md](../../docs/database-schema.md)).

**Bối cảnh:**
- Backend đã xong: 8 migrations + seeds, `supabase db reset` pass, local stack chạy ở `:54321`.
- `AwardsService` đã gọi Supabase qua REST (URLSession + PostgREST) — pattern tham chiếu.
- Còn lại các service đang stub (`return []` / `.sample` / `throw`).
- Login mới có **dev-bypass** (vào thẳng Home), chưa có session thật.

## Quyết định kiến trúc
- **Cài Supabase Swift SDK (SPM)** làm client chung cho Auth + Database. Lý do: Google OAuth + session refresh + tự gắn JWT vào PostgREST/RPC (RLS theo `auth.uid()`) — tự làm raw rất dễ sai. (Alt: raw REST + ASWebAuthenticationSession — nhiều code, bỏ.)
- Services bọc mọi call Supabase; **ViewModels/Views không import Supabase** (theo `ios-development.md`).
- DTO `Decodable` (snake_case) → map sang domain model. Map id value-icon DB ↔ `SunValueIcon`.
- Thêm 1 RPC `get_profile(p_id)` trả JSON gộp (profile + dept + hero tier + icons + stats) → màn Profile gọi 1 lần.

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

**Increment 2 Batch 3 (2026-06-01, Kudos READ) — Build SUCCEEDED, Review 7/10 0-critical (H1/H2/L3 fixes applied), end-to-end verified**

| Phase | Status | Notes |
|-------|--------|-------|
| P1 Foundation | **PARTIAL** | REST client + RPC `get_profile(p_id)` done (migration applied, verified); SDK client + auth (SupabaseClientProvider) deferred to implementation |
| P2 Auth | **DONE** | AuthService: real local email/password sign-in (GoTrue REST) + session restore + sign-out; JWT set on SupabaseRESTClient. Google OAuth dev alias (signInWithGoogle = test user seeded); real Google OAuth deferred to prod. Build: SUCCEEDED · Review: 0-critical. |
| P3 Models/DTO | **PARTIAL** | `SunValueIcon.dbId` + `init?(dbId:)`, `Kudo.title`, `ProfileDTO` (maps to User + stats) done; KudoDTO + full Kudo recipient alignment pending |
| P4 Read services | **DONE (Kudos READ)** | ContentService + KudoService.listAllKudos/listKudos/listReceivedKudos wired to live DB (list_kudos RPC w/ pagination, recipient/sender filters, anonymity from kudos_public view). Board feed, All Kudos, Profile received-kudos sections verified w/ real data. Hashtag/department filters on board not yet wired (server-side filter present, UI ignore). AwardService/hashtags/departments still pending. |
| P5 User services | **PARTIAL** | `UserService`: fetchCurrentUser (get_profile RPC) + fetchProfileStats (v_profile_stats) wired; live DB verified. KudoService.sendKudo/react/unreact/viewKudo, SecretBox, Notification, search pending. |
| P6 Integration & verify | pending | P4 Kudos read ✓, P5 partial ✓; remaining: Kudo send/react, Secret Box, Notifications, search, other-profile, hashtag/dept board filters. |

**Increment 2 Batch 1 (Auth-Independent) — COMPLETED:**
- ✅ `supabase/migrations/20260601000800_get_profile_rpc.sql` — `get_profile(p_id)` RPC (composed profile JSON: user + dept + hero tier + icons + stats), SECURITY DEFINER, grant to `authenticated` only (PUBLIC execute revoked)
- ✅ `Models/SunValueIcon.swift` — added `dbId` property + `init?(dbId:)` (DB slug ↔ case mapper)
- ✅ `Models/Kudo.swift` — added `title: String?` (optional danh hiệu/heading)
- ✅ `Services/ProfileDTO.swift` — decode layer for `get_profile` RPC JSON → `User` + `ProfileStatsData` (consumed in P5)
- ✅ Build: SUCCEEDED
- ✅ Review: 0 critical (2 fixes applied)
- ✅ `get_profile` RPC verified end-to-end

**Increment 2 Batch 3 (Kudos READ) — COMPLETED:**
- ✅ `supabase/migrations/20260601000900_list_kudos_rpc.sql` + `20260601001000_refactor_kudos_read.sql` — `list_kudos(p_limit, p_offset, p_recipient, p_sender)` RPC composes kudos JSON from `kudos_public` view, page-size capped, optional recipient/sender filters for board + profile filtering
- ✅ `KudoService` — KudoDTO decode layer; `listAllKudos(page)` + `listKudos(board feed)` + `listReceivedKudos(userId)` wired to live `list_kudos` RPC (removed dead mockFeed)
- ✅ `ProfileViewModel` — kudos property now reads user's RECEIVED kudos (not global feed); received/sent counts from real `v_kudos_stats` view (fixed regression)
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
