select o.name as "Publisher",m.title as "MiniReel",e.device_category as "Device Type",
e.splash_sessions as "Views",v.mr_total_sessions as "Launches",
--(case when mr_sessions > 0 then mr_session_duration / mr_sessions else 0 end  || 'seconds')::interval as avg_mr_duration,
round((case when v.mr_sessions > 0 then v.mr_session_duration::numeric / v.mr_sessions::numeric else 0::numeric end ),2) as "Avg. Time in MiniReel",
round((case when e.splash_sessions > 0 then v.mr_total_sessions::numeric / e.splash_sessions::numeric else 0::numeric end),4) as "Launch Rate",
round((case when v.mr_total_sessions > 0 then v.mr_bounce_sessions::numeric / v.mr_total_sessions::numeric else 0::numeric end),4) as "MiniReel Bounce Rate"
from dim.minireel m
inner join dim.org o on m.org_id = o.org_id and m.end_ts = o.end_ts
left join (
	select experience_id,device_category,sum(sessions) as splash_sessions
	from fct.mr_embeds_by_device
	where rec_ts >= '2014-07-16 04:00:00+00'
	group by experience_id,device_category
) e on m.experience_id = e.experience_id
left join (
	select experience_id, device_category,sum(coalesce(sessions,0)) as mr_sessions, 
	sum(coalesce(session_duration,0)) as mr_session_duration,sum(coalesce(bounce_sessions,0)) as mr_bounce_sessions, sum(coalesce(sessions,0) + coalesce(bounce_sessions,0)) as mr_total_sessions
	from fct.mr_views_by_device
	where rec_ts >= '2014-07-16 04:00:00+00'
	group by experience_id,device_category
) v on e.experience_id = v.experience_id and e.device_category = v.device_category
WHERE m.end_ts = dim.sp_end_of_time() and o.name <> 'Cinema6'
order by o.name,m.title;
