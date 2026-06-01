# Phase 04 — Read-public services (no auth needed)

**Priority:** High · **Status:** PARTIAL—Kudos READ DONE (2026-06-01 Batch 3); ContentService + KudoService.listAllKudos/listKudos/listReceivedKudos wired to `list_kudos` RPC; AwardService/hashtags/departments/board-filters pending · **Depends:** P01, P03

## Goal
Wire the services backing public, read-only screens so they show real data with the anon key — visible result without login.

## Steps
1. **`ContentService`**:
   - `communityStandards()` → GET `content_sections?document_id=eq.community_standards&order=display_order.asc` → `[ContentSection]` → `CommunityStandard`.
   - `rules()` → fetch `content_documents` (title) + `content_sections?document_id=eq.rules` (text) + `hero_tiers` + `value_icons` (composed for the Rules screen).
2. **`AwardService`**:
   - `awardDetail(type)` → `awards?id=eq.<id>` + `award_criteria?award_id=eq.<id>&order=display_order` → `Award`.
   - `fetchAwards(userId)` → `award_recipients?profile_id=eq.<id>&select=*,awards(*)`.
3. **`AwardsService`** (Home): keep working; optionally migrate to `SupabaseClientProvider` for DRY.
4. **`KudoService`**:
   - `listAllKudos(page)` → `kudos_public?select=...&order=created_at.desc` with `Range` pagination (embed sender/recipient profiles, hashtags, reaction_count).
   - `listKudos(filter)` → same + filter by hashtag/department.
   - `listHashtags()` → `hashtags`.
5. **`UserService.listDepartments()`** → `departments`.

## Files
- modify: `Services/ContentService.swift`, `Services/AwardService.swift`, `Services/AwardsService.swift`, `Services/KudoService.swift`, `Services/UserService.swift`

## Success criteria
- Without logging in (anon): Kudos board / All Kudos, Tiêu chuẩn cộng đồng, Thể lệ, Awards detail render real seeded data.
- `// TODO: Supabase` markers removed from these methods; errors surface via existing error enums.
