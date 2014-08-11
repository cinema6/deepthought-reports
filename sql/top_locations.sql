select publisher,mr_id,minireel,hostname,url,pageviews
from (
	select publisher,mr_id,minireel,hostname,url,pageviews,
	rank() OVER (PARTITION BY publisher,mr_id,minireel order by pageviews desc)
	from (
		select o.name as publisher,m.experience_id as mr_id,m.title as minireel,l.hostname,l.url,sum(l.pageviews) as pageviews,
		rank() OVER (PARTITION BY o.name,m.experience_id,m.title,l.hostname order by sum(l.pageviews) desc,url asc)
		from dim.minireel m
		inner join dim.org o on m.org_id = o.org_id and o.end_ts = m.end_ts
		inner join fct.mr_locations l on m.experience_id = l.experience_id 
		where m.end_ts = dim.sp_end_of_time() and not l.hostname like '%adnxs%' and l.date_key = 20140724
		group by o.name,m.experience_id,m.title,l.hostname,l.url
	) as i
	where rank = 1
) as o
where rank <= 10
order by publisher,minireel,mr_id,rank
