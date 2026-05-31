-- Hero tiers (Rules screen). Keyed on number of DISTINCT senders who sent you Kudos.
insert into public.hero_tiers (id, label, min_senders, max_senders, description, display_order) values
    ('new',    'New Hero',    1,  4,    'Hành trình lan tỏa điều tốt đẹp bắt đầu – những lời cảm ơn và ghi nhận đầu tiên đã tìm đến bạn.', 1),
    ('rising', 'Rising Hero', 5,  9,    'Hành trình lan tỏa điều tốt đẹp bắt đầu – những lời cảm ơn và ghi nhận đầu tiên đã tìm đến bạn.', 2),
    ('super',  'Super Hero',  10, 20,   'Bạn đã trở thành biểu tượng được tin tưởng và yêu quý, người luôn sẵn sàng hỗ trợ và được nhiều đồng đội nhớ đến.', 3),
    ('legend', 'Legend Hero', 21, null, 'Bạn đã trở thành biểu tượng được tin tưởng và yêu quý, người luôn sẵn sàng hỗ trợ và được nhiều đồng đội nhớ đến.', 4)
on conflict (id) do update set
    label = excluded.label, min_senders = excluded.min_senders, max_senders = excluded.max_senders,
    description = excluded.description, display_order = excluded.display_order;
