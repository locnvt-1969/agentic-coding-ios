# Phase 03 — Models & DTO alignment

**Priority:** Blocking · **Status:** pending · **Depends:** P01

## Goal
Align Swift models + add DTOs so DB rows decode cleanly. Shared by P04/P05.

## Steps
1. **`Kudo`** model: add `title: String?` (danh hiệu); keep `recipients: [User]` but populate with the single DB `recipient` (or add `recipient: User`). Keep `resolvedSender` anonymity invariant.
2. **`SunValueIcon`**: add `init?(dbId:)` mapping DB slug → case (`'touch_of_light'`→`.touchOfLight`, `'beyond_the_boundary'`→`.beyondTheBoundary`, …) + a `dbId` var (inverse). Used to decode `user_value_icons`/`value_icons`.
3. **DTOs** (`Decodable`, snake_case) per resource, mapped to domain models inside services:
   - `ProfileDTO` (from `get_profile` JSON: profile + department + hero_label + value_icon ids + stats) → `User` + `ProfileStatsData`.
   - `KudoDTO` (from `kudos_public` + embedded sender/recipient profiles + hashtags + reaction_count, + `has_reacted` if available) → `Kudo`.
   - `ContentSectionDTO` (arrays) → `ContentSection`.
   - `HashtagDTO`, `DepartmentDTO`, `AwardDTO`(+criteria), `NotificationDTO`, `SecretBoxDTO`, `ValueIconDTO`.
4. **Reaction state**: expose `reactionCount` + `hasReacted` for the current user on kudo DTOs (PostgREST: embed `kudo_reactions` filtered by `profile_id=auth.uid()` or a dedicated view) so the heart button reflects state.

## Files
- modify: `Models/Kudo.swift`, `Models/SunValueIcon.swift`
- create: `Services/DTOs/` (per-resource `*DTO.swift`) — keep each small, decoding only.

## Success criteria
- DTOs decode real JSON pulled from the local DB (validate at runtime in P04/P05).
- `SunValueIcon(dbId:)` round-trips all 6 ids.
- No force-unwrap; models stay Codable-compatible.
