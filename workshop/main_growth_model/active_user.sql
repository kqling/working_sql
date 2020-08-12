SELECT
    platform,
    dau.active_date,
    COUNT(distinct case when l.user_pseudo_id is null then dau.user_pseudo_id else null end) as silence_user,
    COUNT(distinct case when l.user_pseudo_id is not null then dau.user_pseudo_id else null end) as active_user
FROM
    (SELECT
        distinct 'Android' as platform,
        user_pseudo_id,
        parse_date("%Y%m%d", _TABLE_SUFFIX) as active_date
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
    WHERE parse_date("%Y%m%d", _TABLE_SUFFIX) between date('2020-07-01') AND CURRENT_DATE()
    AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')) dau   
LEFT JOIN 
    (SELECT
        distinct parse_date("%Y%m%d", _TABLE_SUFFIX) as date,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
    WHERE parse_date("%Y%m%d", _TABLE_SUFFIX) between date('2020-06-20') AND CURRENT_DATE()
    AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')) l 
ON dau.user_pseudo_id = l.user_pseudo_id
AND l.date between DATE_ADD(dau.active_date, INTERVAL -7 day) AND DATE_ADD(dau.active_date, INTERVAL -1 day)
GROUP BY 1,2
UNION ALL
SELECT
    platform,
    dau.active_date,
    COUNT(distinct case when l.user_pseudo_id is null then dau.user_pseudo_id else null end) as silence_user,
    COUNT(distinct case when l.user_pseudo_id is not null then dau.user_pseudo_id else null end) as active_user
FROM
    (SELECT
        distinct 'iOS' as platform,
        user_pseudo_id,
        parse_date("%Y%m%d", _TABLE_SUFFIX) as active_date
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_ios_*`
    WHERE parse_date("%Y%m%d", _TABLE_SUFFIX) between date('2020-07-01') AND CURRENT_DATE()
    AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')) dau   
LEFT JOIN 
    (SELECT
        distinct parse_date("%Y%m%d", _TABLE_SUFFIX) as date,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_ios_*`
    WHERE parse_date("%Y%m%d", _TABLE_SUFFIX) between date('2020-06-20') AND CURRENT_DATE()
    AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')) l 
ON dau.user_pseudo_id = l.user_pseudo_id
AND l.date between DATE_ADD(dau.active_date, INTERVAL -7 day) AND DATE_ADD(dau.active_date, INTERVAL -1 day)
GROUP BY 1,2
ORDER BY 1,2