select o.name as publisher,m.title as minireel,coalesce(days.count_of_days,0) as days_run,
coalesce(e.splash_sessions,0) as loads,coalesce(ee.splash_views,0) as views,coalesce(v.mr_total_sessions,0) as launches,
coalesce(v.mr_sessions,0) as non_bounce_sessions,coalesce(v.mr_bounce_sessions,0) as bounce_sessions,
coalesce(v.mr_session_duration,0) as time_in_minireel
from dim.minireel m
inner join dim.org o on m.org_id = o.org_id and m.end_ts = o.end_ts
left join (
	select experience_id,sum(sessions) as splash_sessions
	from fct.mr_embeds_by_device 
	inner join dim.dates d on  fct.mr_embeds_by_device.date_key = d.date_key
	where d.date between '2015-02-01' and '2015-02-03' and NOT hostname like 'consideringthings.com'
	group by experience_id
) e on m.experience_id = e.experience_id
left join (
		select experience_id,  sum(coalesce(unique_events,0)) as splash_views
		from fct.mr_embed_events_by_device
		inner join dim.dates d on fct.mr_embed_events_by_device.date_key = d.date_key
		where  d.date between '2015-02-01' and '2015-02-03' and event_type = 'Visible' 
		and NOT hostname like 'consideringthings.com'
		group by  experience_id
	) ee on  e.experience_id = ee.experience_id
left join (
	select experience_id, sum(coalesce(sessions,0)) as mr_sessions, 
	sum(coalesce(session_duration,0)) as mr_session_duration,sum(coalesce(bounce_sessions,0)) as mr_bounce_sessions, sum(coalesce(sessions,0) + coalesce(bounce_sessions,0)) as mr_total_sessions
	from fct.mr_views_by_device
	inner join dim.dates d on fct.mr_views_by_device.date_key = d.date_key
	where d.date between '2015-02-01' and '2015-02-03' and NOT hostname like 'consideringthings.com'
	group by experience_id
) v on e.experience_id = v.experience_id 
left join (
	select experience_id,sum(count) as count_of_days
	from (
		select d.date_key,experience_id,1 as count 
		from fct.mr_embeds_by_device 
		inner join dim.dates d on fct.mr_embeds_by_device.date_key = d.date_key
	    where d.date between '2015-02-01' and '2015-02-03' and NOT hostname like 'consideringthings.com'
		group by d.date_key,experience_id
	) as exdays
	group by experience_id
) days on e.experience_id = days.experience_id
WHERE m.end_ts = dim.sp_end_of_time() and o.name = 'Pixable' and coalesce(days.count_of_days,0) > 0
order by o.name,m.title;
