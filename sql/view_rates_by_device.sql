select e.device_category,sum(e.pageviews) as loads,sum(coalesce(ee.events,0)) as views
from dim.minireel m
inner join fct.mr_embeds_by_device e on e.experience_id = m.experience_id
left join fct.mr_embed_events_by_device ee on e.experience_id = ee.experience_id
	AND e.date_key = ee.date_key AND e.hod_key = ee.hod_key
	AND e.hostname = ee.hostname AND e.device_category = ee.device_category
	AND e.os = ee.os AND e.browser = ee.browser AND ee.event_type = 'Visible'
where m.title like '%Ebola%' and m.end_ts = dim.sp_end_of_time()
group by e.device_category
order by e.device_category