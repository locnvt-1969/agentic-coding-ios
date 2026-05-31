-- The 6 Sun* value icons (SunValueIcon). image_name matches Assets.xcassets/Momorph/Content.
insert into public.value_icons (id, label, image_name, display_order) values
    ('revival',            'REVIVAL',             'rules_icon_revival',         1),
    ('touch_of_light',     'TOUCH OF LIGHT',      'rules_icon_touch_of_light',  2),
    ('stay_gold',          'STAY GOLD',           'rules_icon_stay_gold',       3),
    ('flow_to_horizon',    'FLOW TO HORIZON',     'rules_icon_flow_to_horizon', 4),
    ('beyond_the_boundary','BEYOND THE BOUNDARY', 'rules_icon_beyond_boundary', 5),
    ('root_further',       'ROOT FURTHER',        'rules_icon_root_further',    6)
on conflict (id) do update set
    label = excluded.label, image_name = excluded.image_name, display_order = excluded.display_order;
