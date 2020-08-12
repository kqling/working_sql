SELECT
    'Android' as platform,
    format_date('%Y-%m-%d', parse_date("%Y%m%d", _TABLE_SUFFIX)) as date,
    COUNT(distinct if(living_days = 0, user_pseudo_id, null)) as new_user,
    COUNT(distinct user_pseudo_id) as DAU
FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
WHERE parse_date("%Y%m%d", _TABLE_SUFFIX) between date('2020-07-01') AND CURRENT_DATE()
AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')
GROUP BY 1,2
UNION ALL
SELECT
    'iOS' as platform,
    format_date('%Y-%m-%d', parse_date("%Y%m%d", _TABLE_SUFFIX)) as date,
    COUNT(distinct if(living_days = 0, user_pseudo_id, null)) as new_user,
    COUNT(distinct user_pseudo_id) as DAU
FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_ios_*`
WHERE parse_date("%Y%m%d", _TABLE_SUFFIX) between date('2020-07-01') AND CURRENT_DATE()
AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')
GROUP BY 1,2
ORDER BY 1,2