insert into public.awards (id, name, description, thumbnail_name, display_order) values
    ('top-talent', 'Top Talent', 'Giải thưởng Top Talent vinh danh những cá nhân xuất sắc...', 'home-award-card-bg', 1),
    ('top-project', 'Top Project', 'Giải thưởng Top Project vinh danh các tập thể dự án xuất...', 'home-award-card-bg', 2),
    ('top-manager', 'Top Manager', 'Giải thưởng Top Manager vinh danh những nhà quản lý xuất...', 'home-award-card-bg', 3)
on conflict (id) do update set
    name = excluded.name,
    description = excluded.description,
    thumbnail_name = excluded.thumbnail_name,
    display_order = excluded.display_order;
