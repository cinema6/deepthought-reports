
select publisher,date,sum(splash_page_views) as splash_page_views,sum(launches) as launches
from
(
select d.date, o.publisher, e.experience_id,coalesce(e.splash_sessions,0) as splash_page_views,coalesce(v.mr_total_sessions,0) as launches
from dim.dates d
left join (
	select date_key,experience_id,sum(sessions) as splash_sessions
	from fct.mr_embeds_by_device
	group by date_key,experience_id
) e on d.date_key = e.date_key
left join (
	select date_key,experience_id,  sum(coalesce(sessions,0) + coalesce(bounce_sessions,0)) as mr_total_sessions
	from fct.mr_views_by_device
	group by date_key, experience_id
) v on e.date_key = v.date_key and e.experience_id = v.experience_id
inner join (
	select m.experience_id,o.name as publisher
	from dim.minireel m
	inner join dim.org o on m.org_id = o.org_id and m.end_ts = o.end_ts
	where m.end_ts = dim.sp_end_of_time()
) o on o.experience_id = e.experience_id
WHERE d.date_key between 20140701 and 20140731
order by d.date,o.publisher,e.experience_id
) as sub
group by publisher,date
order by publisher,date