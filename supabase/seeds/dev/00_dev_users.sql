-- DEV ONLY — a confirmed test user for local email/password login. NOT for production.
-- Credentials: sunner@sun.com / Password123!
-- The handle_new_user trigger auto-creates the profile; we then enrich it.

delete from auth.users where email = 'sunner@sun.com';

insert into auth.users (
    instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
    created_at, updated_at, confirmation_token, recovery_token,
    email_change_token_new, email_change, raw_app_meta_data, raw_user_meta_data, is_super_admin
) values (
    '00000000-0000-0000-0000-000000000000',
    '1628681b-1e3d-42aa-98ee-bfc315b1503b',
    'authenticated', 'authenticated',
    'sunner@sun.com',
    crypt('Password123!', gen_salt('bf')),
    now(), now(), now(),
    '', '', '', '',
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"full_name":"Huỳnh Dương Xuân Nhật"}'::jsonb,
    false
);

update public.profiles
   set department_id = 'cevc3', role = 'Engineer'
 where id = '1628681b-1e3d-42aa-98ee-bfc315b1503b';

insert into public.user_value_icons (profile_id, value_icon_id) values
    ('1628681b-1e3d-42aa-98ee-bfc315b1503b', 'revival'),
    ('1628681b-1e3d-42aa-98ee-bfc315b1503b', 'stay_gold'),
    ('1628681b-1e3d-42aa-98ee-bfc315b1503b', 'root_further')
on conflict do nothing;
