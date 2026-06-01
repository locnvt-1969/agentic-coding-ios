-- DEV ONLY — a buddy user + sample kudos + reactions so the Kudos board and profiles
-- have real content. sunner = 1628681b-…; buddy created here.

-- ── buddy auth user + profile ────────────────────────────────────────────────
delete from auth.users where email = 'buddy@sun.com';
insert into auth.users (
    instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
    created_at, updated_at, confirmation_token, recovery_token,
    email_change_token_new, email_change, raw_app_meta_data, raw_user_meta_data, is_super_admin
) values (
    '00000000-0000-0000-0000-000000000000',
    'b0000000-0000-0000-0000-000000000002',
    'authenticated', 'authenticated', 'buddy@sun.com',
    crypt('Password123!', gen_salt('bf')), now(), now(), now(),
    '', '', '', '',
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"full_name":"Dương Xuân Huỳnh"}'::jsonb, false
);
update public.profiles set department_id = 'cevc10', role = 'Engineer'
 where id = 'b0000000-0000-0000-0000-000000000002';

-- ── kudos (idempotent via fixed ids) ─────────────────────────────────────────
delete from public.kudos where id in (
    '11111111-0000-0000-0000-000000000001','11111111-0000-0000-0000-000000000002',
    '11111111-0000-0000-0000-000000000003','11111111-0000-0000-0000-000000000004',
    '11111111-0000-0000-0000-000000000005'
);
insert into public.kudos (id, sender_id, recipient_id, title, message, is_anonymous, is_spam, created_at) values
    ('11111111-0000-0000-0000-000000000001','b0000000-0000-0000-0000-000000000002','1628681b-1e3d-42aa-98ee-bfc315b1503b',
     'IDOL GIỚI TRẺ','Cảm ơn người em bình thường nhưng phi thường :D Cảm ơn sự chăm chỉ, cần mẫn của em đã tạo động lực rất nhiều cho cả team.', false, false, '2025-10-30T10:00:00Z'),
    ('11111111-0000-0000-0000-000000000002','b0000000-0000-0000-0000-000000000002','1628681b-1e3d-42aa-98ee-bfc315b1503b',
     null,'Cảm ơn sự hỗ trợ nhiệt tình của bạn trong sprint vừa rồi!', false, false, '2025-10-29T09:00:00Z'),
    ('11111111-0000-0000-0000-000000000003','b0000000-0000-0000-0000-000000000002','1628681b-1e3d-42aa-98ee-bfc315b1503b',
     null,'Một lời cảm ơn ẩn danh dành cho bạn — cứ tiếp tục tỏa sáng nhé!', true, false, '2025-10-28T08:00:00Z'),
    ('11111111-0000-0000-0000-000000000004','1628681b-1e3d-42aa-98ee-bfc315b1503b','b0000000-0000-0000-0000-000000000002',
     'Đồng đội tuyệt vời','Cảm ơn cậu đã luôn sẵn sàng giúp đỡ mọi người!', false, false, '2025-10-27T07:00:00Z'),
    ('11111111-0000-0000-0000-000000000005','b0000000-0000-0000-0000-000000000002','1628681b-1e3d-42aa-98ee-bfc315b1503b',
     null,'...', false, true, '2025-10-26T06:00:00Z');

-- ── hashtags on a couple of kudos ────────────────────────────────────────────
delete from public.kudo_hashtags where kudo_id in (
    '11111111-0000-0000-0000-000000000001','11111111-0000-0000-0000-000000000004'
);
insert into public.kudo_hashtags (kudo_id, hashtag_id) values
    ('11111111-0000-0000-0000-000000000001','dedicated'),
    ('11111111-0000-0000-0000-000000000001','inspiring'),
    ('11111111-0000-0000-0000-000000000004','teamwork');

-- ── reactions (❤️) — unique(kudo, profile) ───────────────────────────────────
delete from public.kudo_reactions where kudo_id in (
    '11111111-0000-0000-0000-000000000001','11111111-0000-0000-0000-000000000002',
    '11111111-0000-0000-0000-000000000004'
);
insert into public.kudo_reactions (kudo_id, profile_id) values
    ('11111111-0000-0000-0000-000000000001','1628681b-1e3d-42aa-98ee-bfc315b1503b'),
    ('11111111-0000-0000-0000-000000000002','1628681b-1e3d-42aa-98ee-bfc315b1503b'),
    ('11111111-0000-0000-0000-000000000004','b0000000-0000-0000-0000-000000000002');

-- ── comments — so the Kudo detail screen has real comment content ────────────
delete from public.kudo_comments where id = 'dddddddd-0000-0000-0000-000000000001';
insert into public.kudo_comments (id, kudo_id, author_id, text, created_at) values
    ('dddddddd-0000-0000-0000-000000000001','11111111-0000-0000-0000-000000000001',
     'b0000000-0000-0000-0000-000000000002','Chúc mừng nhé!', '2026-06-01T02:38:00Z');
