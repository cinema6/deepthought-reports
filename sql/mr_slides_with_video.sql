SELECT o.name as "Firm",m.title as "MiniReel",(c.card_index + 1) as "#",c.title as "Slide", 
--c.video_start,c.video_end,
case 
when coalesce(c.video_start,0) < coalesce(c.video_end,0) then (coalesce(c.video_end,0) - coalesce(c.video_start,0))::varchar(20) || '*'
when not c.video_start is null AND c.video_end is null AND not v.duration is null then (v.duration - c.video_start)::varchar(20) || '*'
when not c.video_end is null AND c.video_start is null then c.video_end::varchar(20) || '*'
when not v.duration is null then v.duration::varchar(10)
end as "Video Length",
pv.avg_time_on_page as "Avg Time on Slide",
pv.pageviews as "Views",
-- pv.exits as "Exits",
vp.events as "Plays",vq1.events as "1st quartile",vq2.events as "2nd quartile",vq3.events as "3rd quartile",vq4.events as "4th quartile",
--ve.events as "End",
round((vq4.events::numeric / vp.events::numeric) ,4) as "Play to Q4 %"
--round((ve.events::numeric / vp.events::numeric) ,4) as "View to End %"
FROM dim.minireel_card c
INNER JOIN dim.minireel m ON c.minireel_key = m.minireel_key
LEFT OUTER JOIN dim.video v on c.video_client_id = v.video_client_id AND v.end_ts = dim.sp_end_of_time()
LEFT OUTER JOIN (
	SELECT experience_id,card_id,sum(unique_pageviews) as pageviews, sum(exits) as exits, 
--	( (case when (sum(pageviews) - sum(exits) ) > 0 then sum(time_on_page) / (sum(pageviews) - sum(exits) ) else 0 end) || 'seconds')::interval as avg_time_on_page
	round( (case when (sum(pageviews) - sum(exits) ) > 0 then sum(time_on_page)::numeric / (sum(pageviews) - sum(exits) )::numeric else 0::numeric end),2 ) as avg_time_on_page
	FROM fct.mr_card_views_by_device where rec_ts >= '2014-07-15 14:00:00+00'	and device_category = 'desktop'
	GROUP BY experience_id, card_id
	ORDER BY experience_id, card_id
) as pv ON pv.experience_id = m.experience_id AND pv.card_id = c.card_id
LEFT OUTER JOIN (
	SELECT 	experience_id, card_id, sum(unique_events) as events
	FROM	fct.mr_video_events_by_device
	WHERE	event_type = 'Play' and rec_ts >= '2014-07-15 14:00:00+00' and device_category = 'desktop'
	GROUP BY experience_id, card_id
	ORDER BY experience_id, card_id
) as vp ON vp.experience_id = m.experience_id AND vp.card_id = c.card_id
LEFT OUTER JOIN (
	SELECT 	experience_id, card_id, sum(unique_events) as events
	FROM	fct.mr_video_events_by_device
	WHERE	event_type = 'Quartile 1' and rec_ts >= '2014-07-15 14:00:00+00' and device_category = 'desktop'
	GROUP BY experience_id, card_id
	ORDER BY experience_id, card_id
) as vq1 ON  vq1.experience_id = m.experience_id AND  vq1.card_id = c.card_id
LEFT OUTER JOIN (
	SELECT 	experience_id, card_id, sum(unique_events) as events
	FROM	fct.mr_video_events_by_device
	WHERE	event_type = 'Quartile 2' and rec_ts >= '2014-07-15 14:00:00+00' and device_category = 'desktop'
	GROUP BY experience_id, card_id
	ORDER BY experience_id, card_id
) as vq2 ON  vq2.experience_id = m.experience_id AND  vq2.card_id = c.card_id
LEFT OUTER JOIN (
	SELECT 	experience_id, card_id, sum(unique_events) as events
	FROM	fct.mr_video_events_by_device
	WHERE	event_type = 'Quartile 3' and rec_ts >= '2014-07-15 14:00:00+00' and device_category = 'desktop'
	GROUP BY experience_id, card_id
	ORDER BY experience_id, card_id
) as vq3 ON  vq3.experience_id = m.experience_id AND  vq3.card_id = c.card_id
LEFT OUTER JOIN (
	SELECT 	experience_id, card_id, sum(unique_events) as events
	FROM	fct.mr_video_events_by_device
	WHERE	event_type = 'Quartile 4' and rec_ts >= '2014-07-15 14:00:00+00' and device_category = 'desktop'
	GROUP BY experience_id, card_id
	ORDER BY experience_id, card_id
) as vq4 ON  vq4.experience_id = m.experience_id AND  vq4.card_id = c.card_id
LEFT OUTER JOIN (
	SELECT 	experience_id, card_id, sum(unique_events) as events
	FROM	fct.mr_video_events_by_device
	WHERE	event_type = 'End' and rec_ts >= '2014-07-15 14:00:00+00' and device_category = 'desktop'
	GROUP BY experience_id, card_id
	ORDER BY experience_id, card_id
) as ve ON  ve.experience_id = m.experience_id AND  ve.card_id = c.card_id
INNER JOIN dim.org o ON m.org_id = o.org_id AND o.end_ts = dim.sp_end_of_time()
WHERE m.end_ts = dim.sp_end_of_time() AND m.title in ('Viral Videos FTW!')
