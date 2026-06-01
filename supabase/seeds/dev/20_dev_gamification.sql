-- DEV ONLY — give the test user (sunner = 1628681b-…) some unopened secret boxes so the
-- Secret Box screen has content to open. Real boxes are auto-granted by the
-- grant_secret_boxes_on_heart trigger (1 per 5 ❤️ received on sent kudos).
-- Idempotent: clear this user's CLOSED dev boxes first, then insert a fixed count.

delete from public.secret_boxes
 where profile_id = '1628681b-1e3d-42aa-98ee-bfc315b1503b' and state = 'closed';

insert into public.secret_boxes (profile_id, state)
select '1628681b-1e3d-42aa-98ee-bfc315b1503b', 'closed'
from generate_series(1, 5);

-- ── gift recipients — so the board's "10 SUNNER NHẬN QUÀ MỚI NHẤT" list has content.
-- (icon_collection = collected all 6 icons; national_kudos = a top-5 most-❤️ kudo.)
delete from public.user_rewards
 where profile_id in ('1628681b-1e3d-42aa-98ee-bfc315b1503b',
                      'b0000000-0000-0000-0000-000000000002');
insert into public.user_rewards (profile_id, reward_id, kudo_id) values
    ('b0000000-0000-0000-0000-000000000002', 'icon_collection', null),
    ('1628681b-1e3d-42aa-98ee-bfc315b1503b', 'national_kudos', '11111111-0000-0000-0000-000000000001'),
    ('b0000000-0000-0000-0000-000000000002', 'national_kudos', '11111111-0000-0000-0000-000000000004');
