SET work_mem = '10MB';
select publisher,date,sum(splash_page_loads) as splash_page_loads,
sum(splash_page_views) as splash_page_views,
sum(launches) as launches
from (
	select d.date, o.publisher, e.experience_id,
	coalesce(e.splash_sessions,0) as splash_page_loads,
	coalesce(ee.splash_views,0) as splash_page_views,
	coalesce(v.mr_total_sessions,0) as launches
	from dim.dates d
	left join (
		select date_key,experience_id,sum(sessions) as splash_sessions
		from fct.mr_embeds_by_device
		where NOT hostname like 'consideringthings.com'
		group by date_key,experience_id
	) e on d.date_key = e.date_key
	left join (
		select date_key,experience_id,  sum(coalesce(unique_events,0)) as splash_views
		from fct.mr_embed_events_by_device
		where NOT hostname like 'consideringthings.com' and event_type = 'Visible'
		group by  date_key,experience_id
	) ee on  e.experience_id = ee.experience_id and e.date_key = ee.date_key
	left join (
		select date_key,experience_id,  sum(coalesce(sessions,0) + coalesce(bounce_sessions,0)) as mr_total_sessions
		from fct.mr_views_by_device
		where NOT hostname like 'consideringthings.com'
		group by date_key, experience_id
	) v on e.date_key = v.date_key and e.experience_id = v.experience_id
	inner join (
		select m.experience_id,o.name as publisher
		from dim.minireel m
		inner join dim.org o on m.org_id = o.org_id and m.end_ts = o.end_ts
		where m.end_ts = dim.sp_end_of_time()
	) o on o.experience_id = e.experience_id
	WHERE d.date between '2015-02-01' and '2015-02-03'
	order by d.date,o.publisher,e.experience_id
) as sub
where publisher = 'Pixable'
group by publisher,date
order by publisher,date
