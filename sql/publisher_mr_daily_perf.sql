select d.date, 
coalesce(e.splash_sessions,0) as splash_page_loads,
coalesce(ee.splash_views,0) as splash_page_views,
coalesce(v.mr_total_sessions,0) as launches,
sessions,bounce_sessions,session_duration,coalesce(users,0) as users
from dim.dates d
left join (
	select date_key,experience_id,sum(sessions) as splash_sessions
	from fct.mr_embeds_by_device where NOT hostname like 'consideringthings.com'
	group by date_key,experience_id
) e on d.date_key = e.date_key
left join (
	select date_key,experience_id,  sum(coalesce(unique_events,0)) as splash_views
	from fct.mr_embed_events_by_device
	where NOT hostname like 'consideringthings.com' and event_type = 'Visible'
	group by  date_key,experience_id
) ee on  e.experience_id = ee.experience_id and e.date_key = ee.date_key
left join (
	select date_key,experience_id,  sum(coalesce(sessions,0) + coalesce(bounce_sessions,0)) as mr_total_sessions,
	sum(coalesce(sessions,0)) as sessions, sum(coalesce(bounce_sessions,0)) as bounce_sessions,
	sum(coalesce(session_duration,0)) as session_duration, sum(coalesce(users,0)) as users
	from fct.mr_views_by_device where NOT hostname like 'consideringthings.com'
	group by date_key, experience_id
) v on e.date_key = v.date_key and e.experience_id = v.experience_id
WHERE d.date BETWEEN '2015-02-01' and '2015-02-03' and e.experience_id = 'e-8caa04bcf0858b'
order by d.date
