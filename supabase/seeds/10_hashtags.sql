insert into public.hashtags (id, name, "group") values
    ('dedicated',   '#Dedicated',   'Values'),
    ('inspiring',   '#Inspiring',   'Values'),
    ('teamwork',    '#Teamwork',    'Values'),
    ('creative',    '#Creative',    'Values'),
    ('supportive',  '#Supportive',  'Values'),
    ('proactive',   '#Proactive',   'Values')
on conflict (id) do update set name = excluded.name, "group" = excluded."group";
