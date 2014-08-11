select o.name as "Publisher",m.title as "MiniReel",days.count_of_days as "Days Run",
e.splash_sessions as "Views",v.mr_total_sessions as "Launches",
--(case when mr_sessions > 0 then mr_session_duration / mr_sessions else 0 end  || 'seconds')::interval as avg_mr_duration,
round((case when v.mr_sessions > 0 then v.mr_session_duration::numeric / v.mr_sessions::numeric else 0::numeric end ),2) as "Avg. Time in MiniReel",
round((case when e.splash_sessions > 0 then v.mr_total_sessions::numeric / e.splash_sessions::numeric else 0::numeric end),4) as "Launch Rate",
round((case when v.mr_total_sessions > 0 then v.mr_bounce_sessions::numeric / v.mr_total_sessions::numeric else 0::numeric end),4) as "MiniReel Bounce Rate"
from dim.minireel m
inner join dim.org o on m.org_id = o.org_id and m.end_ts = o.end_ts
left join (
	select experience_id,sum(sessions) as splash_sessions
	from fct.mr_embeds_by_device --where date_key = 20140729 -- between 20140728 and 20140730
	group by experience_id
) e on m.experience_id = e.experience_id
left join (
	select experience_id, sum(coalesce(sessions,0)) as mr_sessions, 
	sum(coalesce(session_duration,0)) as mr_session_duration,sum(coalesce(bounce_sessions,0)) as mr_bounce_sessions, sum(coalesce(sessions,0) + coalesce(bounce_sessions,0)) as mr_total_sessions
	from fct.mr_views_by_device --where date_key = 20140729 --between 20140728 and 20140730
	group by experience_id
) v on e.experience_id = v.experience_id 
left join (
	select experience_id,sum(count) as count_of_days
	from (
		select date_key,experience_id,1 as count 
		from fct.mr_embeds_by_device 
		group by date_key,experience_id
	) as exdays
	group by experience_id
) days on e.experience_id = days.experience_id
WHERE m.end_ts = dim.sp_end_of_time() and o.name <> 'Cinema6' and not o.name like '%Test%'
order by o.name,m.title;

