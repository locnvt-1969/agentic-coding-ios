insert into public.departments (id, name) values
    ('cevc3',  'CEVC3'),
    ('cevc5',  'CEVC5'),
    ('cevc7',  'CEVC7'),
    ('cevc10', 'CEVC10')
on conflict (id) do update set name = excluded.name;
