select o.name as content_publisher,
case when (u.fname is not null AND u.lname is not null) then u.fname || ' ' || u.lname else u.email end as editor,
u.email as editor_id,
u.user_type,m.title as minireel,m.experience_id as minireel_id,
v.category,
c.slide_count,
(c.has_ballots = 1)::boolean as has_survey,
coalesce(m.access_type,'private') as access_type,
'3-2' as splash_ratio,
'img-text-overlay' as splash_theme
from dim.user u
inner join dim.minireel m on m.created_by = u.user_id AND m.end_ts = u.end_ts
inner join (
	select minireel_key,max(case when ballot_prompt is null then 0 else 1 end) as has_ballots, count(card_id) as slide_count
	from dim.minireel_card
	group by minireel_key
	order by minireel_key
) c on c.minireel_key = m.minireel_key
left join (
	select minireel_key, category, category_count,rank() OVER (partition by minireel_key  order by category_count desc, category asc) as rank
	from (
		select c.minireel_key,v.category, count(v.category) as category_count
		from dim.minireel_card c
		left join dim.video v on c.video_client_id = v.video_client_id and v.end_ts = dim.sp_end_of_time()
		where c.video_client_id is not null
		group by c.minireel_key,v.category
	) as cats
	order by minireel_key,rank() OVER (partition by minireel_key  order by category_count desc)
) v on v.minireel_key = m.minireel_key AND v.rank = 1
inner join dim.org o on o.org_id = m.org_id AND o.end_ts = m.end_ts
where u.end_ts = dim.sp_end_of_time()
order by o.name,u.fname,m.title;


--https://staging.cinema6.com/#/preview/minireel?exp=e-44600505f06f70&title=Doctor%20Who%20Regenerations&splash=img-text-overlay:3%2F2

select * from dim.minireel;