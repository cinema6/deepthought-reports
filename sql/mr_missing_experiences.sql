select hostname,experience_id 
from fct.mr_embeds_by_device
where experience_id not in (
	select experience_id from dim.minireel group by experience_id order by experience_id
) 
group by hostname,experience_id
order by hostname,experience_id
