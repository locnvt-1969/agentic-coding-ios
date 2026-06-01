-- DEV ONLY — give the test user (sunner = 1628681b-…) some unopened secret boxes so the
-- Secret Box screen has content to open. Real boxes are auto-granted by the
-- grant_secret_boxes_on_heart trigger (1 per 5 ❤️ received on sent kudos).
-- Idempotent: clear this user's CLOSED dev boxes first, then insert a fixed count.

delete from public.secret_boxes
 where profile_id = '1628681b-1e3d-42aa-98ee-bfc315b1503b' and state = 'closed';

insert into public.secret_boxes (profile_id, state)
select '1628681b-1e3d-42aa-98ee-bfc315b1503b', 'closed'
from generate_series(1, 5);
