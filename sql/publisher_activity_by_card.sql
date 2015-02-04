SELECT o.name as publisher,m.experience_id,m.title as minireel,(c.card_index + 1) as slide_index,c.title as slide, 
case 
when coalesce(c.video_start,0) < coalesce(c.video_end,0) then (coalesce(c.video_end,0) - coalesce(c.video_start,0))
when not c.video_start is null AND c.video_end is null AND not v.duration is null then (v.duration - c.video_start)
when not c.video_end is null AND c.video_start is null then c.video_end
when not v.duration is null then v.duration
end as video_length,
pv.avg_time_on_page as avg_time_in_slide,
pv.pageviews as views,vw.views as total_views,
vp.events as plays,vq1.events as quartile_1,vq2.events as quartile_2,vq3.events as quartile_3,vq4.events as quartile_4
FROM dim.minireel_card c
INNER JOIN dim.minireel m ON c.minireel_key = m.minireel_key
inner JOIN (
	select experience_id,sum(sessions + bounce_sessions) as views
	from fct.mr_views_by_device
	inner join dim.dates d on fct.mr_views_by_device.date_key = d.date_key
	where (sessions + bounce_sessions) > 0 and d.date between '2015-02-01' and '2015-02-03' and NOT hostname like 'consideringthings.com'
	group by experience_id
) as vw on vw.experience_id = m.experience_id
LEFT OUTER JOIN dim.video v on c.video_client_id = v.video_client_id AND v.end_ts = dim.sp_end_of_time()
LEFT OUTER JOIN (
	SELECT experience_id,card_id,sum(unique_pageviews) as pageviews, sum(exits) as exits, 
	round( (case when (sum(pageviews) - sum(exits) ) > 0 then sum(time_on_page)::numeric / (sum(pageviews) - sum(exits) )::numeric else 0::numeric end),2 ) as avg_time_on_page
	FROM fct.mr_card_views_by_device
	inner join dim.dates d on fct.mr_card_views_by_device.date_key = d.date_key
	where  d.date between '2015-02-01' and '2015-02-03' and NOT hostname like 'consideringthings.com'
	GROUP BY experience_id, card_id
	ORDER BY experience_id, card_id
) as pv ON pv.experience_id = m.experience_id AND pv.card_id = c.card_id
LEFT OUTER JOIN (
	SELECT 	experience_id, card_id, sum(unique_events) as events
	FROM	fct.mr_video_events_by_device
	inner join dim.dates d on fct.mr_video_events_by_device.date_key = d.date_key
	WHERE	event_type = 'Play' and d.date between '2015-02-01' and '2015-02-03' and NOT hostname like 'consideringthings.com'
	GROUP BY experience_id, card_id
	ORDER BY experience_id, card_id
) as vp ON vp.experience_id = m.experience_id AND vp.card_id = c.card_id
LEFT OUTER JOIN (
	SELECT 	experience_id, card_id, sum(unique_events) as events
	FROM	fct.mr_video_events_by_device
	inner join dim.dates d on fct.mr_video_events_by_device.date_key = d.date_key
	WHERE	event_type = 'Quartile 1' and d.date between '2015-02-01' and '2015-02-03' and NOT hostname like 'consideringthings.com'
	GROUP BY experience_id, card_id
	ORDER BY experience_id, card_id
) as vq1 ON  vq1.experience_id = m.experience_id AND  vq1.card_id = c.card_id
LEFT OUTER JOIN (
	SELECT 	experience_id, card_id, sum(unique_events) as events
	FROM	fct.mr_video_events_by_device
	inner join dim.dates d on fct.mr_video_events_by_device.date_key = d.date_key
	WHERE	event_type = 'Quartile 2' and d.date between '2015-02-01' and '2015-02-03' and NOT hostname like 'consideringthings.com'
	GROUP BY experience_id, card_id
	ORDER BY experience_id, card_id
) as vq2 ON  vq2.experience_id = m.experience_id AND  vq2.card_id = c.card_id
LEFT OUTER JOIN (
	SELECT 	experience_id, card_id, sum(unique_events) as events
	FROM	fct.mr_video_events_by_device
	inner join dim.dates d on fct.mr_video_events_by_device.date_key = d.date_key
	WHERE	event_type = 'Quartile 3' and d.date between '2015-02-01' and '2015-02-03' and NOT hostname like 'consideringthings.com'
	GROUP BY experience_id, card_id
	ORDER BY experience_id, card_id
) as vq3 ON  vq3.experience_id = m.experience_id AND  vq3.card_id = c.card_id
LEFT OUTER JOIN (
	SELECT 	experience_id, card_id, sum(unique_events) as events
	FROM	fct.mr_video_events_by_device
	inner join dim.dates d on fct.mr_video_events_by_device.date_key = d.date_key
		WHERE	event_type = 'Quartile 4' and d.date between '2015-02-01' and '2015-02-03' and NOT hostname like 'consideringthings.com'
	GROUP BY experience_id, card_id
	ORDER BY experience_id, card_id
) as vq4 ON  vq4.experience_id = m.experience_id AND  vq4.card_id = c.card_id
INNER JOIN dim.org o ON m.org_id = o.org_id AND o.end_ts = dim.sp_end_of_time()
WHERE m.end_ts = dim.sp_end_of_time() and o.name = 'Pixable'
order by m.title,m.experience_id,c.card_index
