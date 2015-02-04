select e.device_category as device,
e.splash_sessions as loads,
coalesce(ee.splash_views,0) as views,
v.mr_total_sessions as launches,
v.mr_sessions,v.mr_bounce_sessions,v.mr_session_duration
from dim.minireel m
left join (
	select experience_id,device_category,sum(sessions) as splash_sessions
	from fct.mr_embeds_by_device
	inner join dim.dates d on d.date_key = fct.mr_embeds_by_device.date_key
	where experience_id = 'e-8caa04bcf0858b' and d.date  BETWEEN '2015-02-01' AND '2015-02-03' 
	and NOT hostname like 'consideringthings.com'
	group by experience_id,device_category
) e on m.experience_id = e.experience_id
left join (
		select experience_id, device_category, sum(coalesce(unique_events,0)) as splash_views
		from fct.mr_embed_events_by_device
		inner join dim.dates d on fct.mr_embed_events_by_device.date_key = d.date_key
		where  experience_id = 'e-8caa04bcf0858b' and d.date between '2015-02-01' and '2015-02-03' and event_type = 'Visible' 
		and NOT hostname like 'consideringthings.com'
		group by  experience_id, device_category
	) ee on  e.experience_id = ee.experience_id and e.device_category = ee.device_category
left join (
	select experience_id, device_category,sum(coalesce(sessions,0)) as mr_sessions, 
	sum(coalesce(session_duration,0)) as mr_session_duration,sum(coalesce(bounce_sessions,0)) as mr_bounce_sessions, sum(coalesce(sessions,0) + coalesce(bounce_sessions,0)) as mr_total_sessions
	from fct.mr_views_by_device
	inner join dim.dates d on d.date_key = fct.mr_views_by_device.date_key
	where experience_id = 'e-8caa04bcf0858b' and d.date  BETWEEN '2015-02-01' AND '2015-02-03'  
	and NOT hostname like 'consideringthings.com'
	group by experience_id,device_category
) v on e.experience_id = v.experience_id and e.device_category = v.device_category
WHERE m.end_ts = dim.sp_end_of_time() and m.experience_id = 'e-8caa04bcf0858b'
order by e.device_category
