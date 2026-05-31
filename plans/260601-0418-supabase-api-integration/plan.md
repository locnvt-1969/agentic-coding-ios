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

**Increment 2 (2026-06-01, Batch 1 Groundwork) — Build SUCCEEDED, Review 0-critical (2 fixes), end-to-end verified**

| Phase | Status | Notes |
|-------|--------|-------|
| P1 Foundation | **PARTIAL** | REST client + RPC `get_profile(p_id)` done (migration applied, verified); SDK client + auth (SupabaseClientProvider) deferred to implementation |
| P2 Auth | pending | Deferred; blocks real session + user-context reads |
| P3 Models/DTO | **PARTIAL** | `SunValueIcon.dbId` + `init?(dbId:)`, `Kudo.title`, `ProfileDTO` (maps to User + stats) done; KudoDTO + full Kudo recipient alignment pending |
| P4 Read services | **PARTIAL** | `ContentService` wired (reads `content_sections` live); KudoService/AwardService/hashtags/departments pending |
| P5 User services | pending | Blocked on P2 (auth); deferred to implementation phase |
| P6 Integration & verify | pending | Deferred pending P5 completion |

**Increment 2 Groundwork Deliverables (auth-independent baseline):**
- ✅ `supabase/migrations/20260601000800_get_profile_rpc.sql` — `get_profile(p_id)` RPC (composed profile JSON: user + dept + hero tier + icons + stats), SECURITY DEFINER, grant to `authenticated` only (PUBLIC execute revoked)
- ✅ `Models/SunValueIcon.swift` — added `dbId` property + `init?(dbId:)` (DB slug ↔ case mapper)
- ✅ `Models/Kudo.swift` — added `title: String?` (optional danh hiệu/heading)
- ✅ `Services/ProfileDTO.swift` — decode layer for `get_profile` RPC JSON → `User` + `ProfileStatsData` (consumed in P5)
- ✅ Build: SUCCEEDED
- ✅ Review: 0 critical (2 fixes applied)
- ✅ `get_profile` RPC verified end-to-end

**Follow-ups logged (do not implement):**
- P5 gate: `SupabaseRESTClient` needs `post(rpc:)` method before wiring get_profile (currently GET-only)
- P5: map RPC NULL (unknown id) → `UserError.notFound` in service layer
- SECURITY: all custom Postgres functions default to PUBLIC EXECUTE; `grant_national_kudos` (SECURITY DEFINER, writes `user_rewards`) currently PUBLIC-callable — revoke EXECUTE from PUBLIC on gamification/notification functions in migration 20260601000700 during P2 hardening

**Remaining Increment 2 work (deferred to implementation):**
- P1 rest: SDK installation + SupabaseClientProvider + HTTP client wiring
- P2 full: Google OAuth + session restore/sign-out + router gate
- P3 rest: KudoDTO + recipient alignment
- P4 rest: KudoService + AwardService + hashtags/departments wired
- P5 full: sendKudo + reactions + profile + secret box + notifications via SDK/RPC
- P6 full: integration + end-to-end verification
