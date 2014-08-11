select o.name as "Publisher", case when u.fname = 'null' then u.email else u.fname || ' ' || u.lname end as "Editor",
m.title as "MiniReel",c.title as "Slide Title",c.card_index + 1 as "Slide No.", 
coalesce(v.title,'unknown') as "Video Title",coalesce(v.channel,'unknown') as "Video Channel",
case v.source when 'YouTube' then 'https://www.youtube.com/watch?v=' || v.video_id else null end as video_url,
v.source as "Source", v.status as "Status", 
v.start_ts as status_date
from dim.video v
inner join dim.minireel_card c on c.video_client_id = v.video_client_id
inner join dim.minireel m on c.minireel_key = m.minireel_key AND m.end_ts = dim.sp_end_of_time()
inner join dim.org o on m.org_id = o.org_id AND o.end_ts = dim.sp_end_of_time()
inner join dim.user u on m.created_by = u.user_id and u.end_ts = dim.sp_end_of_time()
WHERE v.status <> 'ok' AND v.end_ts = dim.sp_end_of_time();
