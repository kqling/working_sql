create table if not exists `blockpuzzle-f21e1.warehouse.ad`
as 
select 
    le.user_pseudo_id,
    le.living_days,
    ri.create_date,
    ri.uuid,
    ri.advertising_id,
    ri.country,
    ri.media_source,
    ri.app_version 
from 
    (select 
        date,
        user_pseudo_id,
        living_days 
    from `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*` 
    where date between '2020-09-18' and '2020-09-20' 
    and living_days between 0 and 2 
    group by 1,2,3) le 
left join `blockpuzzle-f21e1.warehouse.xinyao_temp_af_bigquery_bigquery_new_user` ri 
on le.user_pseudo_id = ri.user_pseudo_id