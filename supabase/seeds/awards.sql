insert into public.awards (id, name, description, thumbnail_name, display_order) values
    ('top-talent', 'Top Talent', 'Giải thưởng Top Talent vinh danh những cá nhân xuất sắc...', 'home-award-card-bg', 1),
    ('top-project', 'Top Project', 'Giải thưởng Top Project vinh danh các tập thể dự án xuất...', 'home-award-card-bg', 2),
    ('top-manager', 'Top Manager', 'Giải thưởng Top Manager vinh danh những nhà quản lý xuất...', 'home-award-card-bg', 3)
on conflict (id) do update set
    name = excluded.name,
    description = excluded.description,
    thumbnail_name = excluded.thumbnail_name,
    display_order = excluded.display_order;

-- Criteria lines shown on the award detail screen.
delete from public.award_criteria where award_id in ('top-talent','top-project','top-manager');
insert into public.award_criteria (award_id, line_text, display_order) values
    ('top-talent',  'Cá nhân có đóng góp nổi bật trong năm.',        1),
    ('top-talent',  'Được đồng đội ghi nhận và đề cử.',              2),
    ('top-project', 'Dự án đạt kết quả xuất sắc, tạo tác động lớn.', 1),
    ('top-project', 'Tinh thần hợp tác và sáng tạo của cả nhóm.',    2),
    ('top-manager', 'Nhà quản lý dẫn dắt đội ngũ hiệu quả.',         1),
    ('top-manager', 'Truyền cảm hứng và phát triển con người.',      2);
