SELECT
    'Android' as platform,
    concat(substr(_table_suffix,0,4),'-',substr(_table_suffix,5,2),'-',substr(_table_suffix,7,2)) as date,
    COUNT(distinct CASE when living_days = 0 then user_pseudo_id else null end) as new_user,
    COUNT(distinct user_pseudo_id) as DAU
FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`,
UNNEST(event_params) as evt
WHERE cast(concat(substr(_table_suffix,0,4),'-',substr(_table_suffix,5,2),'-',substr(_table_suffix,7,2)) as date) between cast('2020-03-01' as date) AND CURRENT_DATE()
AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')
GROUP BY 1,2
UNION ALL
SELECT
    'iOS' as platform,
    concat(substr(_table_suffix,0,4),'-',substr(_table_suffix,5,2),'-',substr(_table_suffix,7,2)) as date,
    COUNT(distinct CASE when living_days = 0 then user_pseudo_id else null end) as new_user,
    COUNT(distinct user_pseudo_id) as DAU
FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_ios_*`,
UNNEST(event_params) as evt
WHERE cast(concat(substr(_table_suffix,0,4),'-',substr(_table_suffix,5,2),'-',substr(_table_suffix,7,2)) as date) between cast('2020-03-01' as date) AND CURRENT_DATE()
AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')
GROUP BY 1,2
ORDER BY 1,2