insert into public.rewards (id, title, description) values
    ('icon_collection', 'Quà bí ẩn sưu tập icon', 'Sưu tập trọn bộ 6 icon của SAA 2025 để nhận quà bí ẩn.'),
    ('national_kudos',  'Quà Kudos Quốc Dân',     'Dành cho tác giả của 5 Kudos nhận nhiều tim nhất toàn Sun*.')
on conflict (id) do update set title = excluded.title, description = excluded.description;
