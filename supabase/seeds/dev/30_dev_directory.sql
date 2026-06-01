-- DEV ONLY — 20 sample Sunners across the 4 departments so the Send-Kudo recipient
-- search has real people to pick. They never sign in; profiles are auto-created by the
-- on_auth_user_created trigger (full_name comes from raw_user_meta_data), then each is
-- assigned a department + role. Idempotent: delete the dev directory users first
-- (FK cascade drops their profiles).

delete from auth.users where email like 'dir%@dev.sun.com';

-- 20 auth users → trigger provisions a profile row for each.
insert into auth.users (
    instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
    created_at, updated_at, confirmation_token, recovery_token,
    email_change_token_new, email_change, raw_app_meta_data, raw_user_meta_data, is_super_admin
)
select
    '00000000-0000-0000-0000-000000000000',
    ('aaaa0000-0000-0000-0000-' || lpad(d.n::text, 12, '0'))::uuid,
    'authenticated', 'authenticated',
    'dir' || d.n || '@dev.sun.com',
    crypt('Password123!', gen_salt('bf')), now(), now(), now(),
    '', '', '', '',
    '{"provider":"email","providers":["email"]}'::jsonb,
    jsonb_build_object('full_name', d.full_name), false
from (values
    (1,  'Nguyễn Văn An'),     (2,  'Trần Thị Bích Ngọc'), (3,  'Lê Hoàng Long'),
    (4,  'Phạm Thu Hà'),       (5,  'Hoàng Minh Tuấn'),    (6,  'Vũ Thị Lan Anh'),
    (7,  'Đặng Quốc Bảo'),     (8,  'Bùi Thị Mai'),        (9,  'Đỗ Khánh Duy'),
    (10, 'Ngô Thanh Tâm'),     (11, 'Dương Hải Yến'),      (12, 'Phan Văn Khôi'),
    (13, 'Trịnh Thu Trang'),   (14, 'Lý Gia Huy'),         (15, 'Mai Phương Thảo'),
    (16, 'Cao Đức Anh'),       (17, 'Tô Ngọc Hân'),        (18, 'Hồ Việt Hùng'),
    (19, 'Đinh Thị Quỳnh'),    (20, 'Lương Tuấn Kiệt')
) as d(n, full_name);

-- Distribute across the 4 departments (round-robin → 5 each) with a varied role.
update public.profiles p
set department_id = (array['cevc3','cevc5','cevc7','cevc10'])[1 + ((d.idx - 1) % 4)],
    role          = (array['Engineer','Designer','Product Manager','QA Engineer','Business Analyst'])[1 + ((d.idx - 1) % 5)]
from (
    select u.id, (substring(u.email from 'dir([0-9]+)@'))::int as idx
    from auth.users u
    where u.email like 'dir%@dev.sun.com'
) d
where p.id = d.id;
