-- Static content: Community Standards ("Tiêu chuẩn chung") + Rules ("Thể lệ").

insert into public.content_documents (id, title) values
    ('community_standards', 'Tiêu chuẩn chung'),
    ('rules',               'Thể lệ')
on conflict (id) do update set title = excluded.title;

delete from public.content_sections where document_id in ('community_standards','rules');

-- ── Community Standards ────────────────────────────────────────────────────────
insert into public.content_sections
    (document_id, title, lead_paragraph, body, numbered_items, bullet_items, highlight, display_order)
values
(
    'community_standards', 'Tiêu chuẩn cộng đồng',
    'Tiêu chuẩn Cộng đồng (Community Standards) được xây dựng nhằm đảm bảo một môi trường văn minh, an toàn và tích cực cho tất cả thành viên tham gia phong trào ghi nhận, cảm ơn Sun* Kudos.',
    array['Các nội dung phát hiện có một trong những tiêu chí vi phạm bên dưới sẽ được gắn nhãn Spam và được hệ thống chủ động ẩn.'],
    array[
        'Sử dụng từ ngữ thô tục, chửi bậy, hay có nội dung xúc phạm, bôi nhọ.',
        'Đề cập đến các vấn đề chính trị, tôn giáo, phân biệt giới tính.',
        'Chứa số liệu cụ thể (doanh thu, hợp đồng, KPI, khách hàng, mã dự án, số tài khoản…).',
        'Đề cập tên đối tác, khách hàng, tổ chức bên ngoài.',
        'Chứa thông tin cá nhân (email, số điện thoại, địa chỉ, thông tin gia đình).',
        'Gửi lặp lại 3+ tin nhắn có nội dung tương tự nhau trong thời gian ngắn.',
        'Nội dung Kudos quá ngắn (dưới 30 kí tự), không có ngữ cảnh ("Cảm ơn nhiều", "Thanks nhé", "Good job!").',
        'Gửi cho quá nhiều người/nhóm người trong thời gian ngắn (<3s/lời nhắn).',
        'Ngôn từ spam (chỉ chứa ký tự như ".", ",", "...", hay ký tự không có nội dung).',
        'Mức độ "tim" tăng đột biến bất thường (theo hành vi người dùng trung bình).'
    ],
    array[]::text[], null, 1
),
(
    'community_standards', 'Tiêu chuẩn bảo mật',
    'Sunner cam kết bảo vệ thông tin. Mọi thành viên có trách nhiệm bảo mật nội dung chia sẻ trên hệ thống.',
    array[]::text[],
    array[]::text[],
    array[
        'Bảo mật Thông tin: Toàn bộ thông tin Sunner chia sẻ sẽ được bảo mật trên hệ thống.',
        'Phạm vi Chia sẻ: Toàn bộ thông tin nhân sự và dự án trong hệ thống được bảo mật. Sunner vui lòng chỉ chia sẻ trong nội bộ Sun*.'
    ],
    'Liên hệ Hỗ trợ: Mọi thắc mắc, Sunner vui lòng liên hệ đại diện BTC SAA: Slack duong.thi.thuy.an để được hỗ trợ.',
    2
);

-- ── Rules ("Thể lệ") — text blocks; Hero tiers + value icons come from their tables ──
insert into public.content_sections
    (document_id, title, lead_paragraph, body, numbered_items, bullet_items, highlight, display_order)
values
(
    'rules', 'NGƯỜI NHẬN KUDOS: HUY HIỆU HERO CHO NHỮNG ẢNH HƯỞNG TÍCH CỰC',
    'Dựa trên số lượng đồng đội gửi trao Kudos, bạn sẽ sở hữu Huy hiệu Hero tương ứng, được hiển thị trực tiếp cạnh tên profile',
    array[]::text[], array[]::text[], array[]::text[], null, 1
),
(
    'rules', 'NGƯỜI GỬI KUDOS: SƯU TẬP TRỌN BỘ 6 ICON, NHẬN NGAY PHẦN QUÀ BÍ ẨN',
    null,
    array[
        'Mỗi lời Kudos bạn gửi sẽ được đăng tải trên hệ thống và nhận về những lượt ❤️ từ cộng đồng Sunner. Cứ mỗi 5 lượt ❤️, bạn sẽ được mở 1 Secret Box, với cơ hội nhận về một trong 6 icon độc quyền của SAA.',
        'Những Sunner thu thập trọn bộ 6 icon sẽ nhận về một phần quà bí ẩn từ SAA 2025.'
    ],
    array[]::text[], array[]::text[], null, 2
),
(
    'rules', 'KUDOS QUỐC DÂN',
    null,
    array['5 Kudos nhận về nhiều ❤️ nhất toàn Sun* sẽ chính thức trở thành Kudos Quốc Dân và được trao phần quà đặc biệt từ SAA 2025: Root Further.'],
    array[]::text[], array[]::text[], null, 3
);
