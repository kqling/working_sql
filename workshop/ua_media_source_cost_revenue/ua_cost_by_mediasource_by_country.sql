select
    c.date,
    c.country_code,
    c.media_source,
    sum(c.spend) as spend
from
    (select distinct media_source, app_id, platform
    from `foradmobapi.learnings_data_warehouse.dim_dwd_ua_application_a` 
    where production_id = '5d0b34d6883d6a000119ed23') p
INNER JOIN `foradmobapi.learnings_data_warehouse.fact_dwd_ua_campaignSpend_di_20200806` c 
ON c.media_source = p.media_source
and c.app_id = p.app_id
and ifnull(c.platform,'nt') = ifnull(p.platform,'nt')
and c.country_code = 'US'
group by 1,2,3;