SELECT
    platform,
    dau.active_date,
    case when living_days = 0 then 'new'
         when l.user_pseudo_id is null then 'silence' 
         else 'active' end as type,
    COUNT(distinct dau.user_pseudo_id) as users,
    COUNT(distinct game.user_pseudo_id) as start_game_users,
    SUM(game_num) as game_num,
    SUM(crush_time) as crush_time,
    SUM(crush_rows) as crush_rows
FROM
    (SELECT
        distinct 'Android' as platform,
        user_pseudo_id,
        living_days,
        parse_date("%Y%m%d", _TABLE_SUFFIX) as active_date
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
    WHERE parse_date("%Y%m%d", _TABLE_SUFFIX) between date('2020-07-01') AND CURRENT_DATE()
    AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')
    ) dau   
LEFT JOIN 
    (SELECT
        distinct parse_date("%Y%m%d", _TABLE_SUFFIX) as date,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
    WHERE parse_date("%Y%m%d", _TABLE_SUFFIX) between date('2020-06-20') AND CURRENT_DATE()
    AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')) l 
ON dau.user_pseudo_id = l.user_pseudo_id
AND l.date between DATE_ADD(dau.active_date, INTERVAL -7 day) AND DATE_ADD(dau.active_date, INTERVAL -1 day)
LEFT JOIN
    (SELECT
        parse_date("%Y%m%d", _TABLE_SUFFIX) as date,
        user_pseudo_id,
        count(distinct case when evt.key = 'play_count' then evt.value else null end) as game_num,
        count(case when evt.key = 'combo_type' then 1 else null end) as crush_time,
        sum(case when evt.key = 'combo_type' then cast(evt.value as int64) else 0 end) as crush_rows
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`,
    unnest(event_params) as evt
    WHERE parse_date("%Y%m%d", _TABLE_SUFFIX) between date('2020-07-01') AND CURRENT_DATE()
    AND event_name = 'act_combo' 
    GROUP BY 1,2) game 
ON game.date = dau.active_date 
AND game.user_pseudo_id = dau.user_pseudo_id
GROUP BY 1,2,3
UNION ALL
SELECT
    platform,
    dau.active_date,
    case when living_days = 0 then 'new'
         when l.user_pseudo_id is null then 'silence' 
         else 'active' end as type,
    COUNT(distinct dau.user_pseudo_id) as users,
    COUNT(distinct game.user_pseudo_id) as start_game_users,
    SUM(game_num) as game_num,
    SUM(crush_time) as crush_time,
    SUM(crush_rows) as crush_rows
FROM
    (SELECT
        distinct 'iOS' as platform,
        user_pseudo_id,
        living_days,
        parse_date("%Y%m%d", _TABLE_SUFFIX) as active_date
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_ios_*`
    WHERE parse_date("%Y%m%d", _TABLE_SUFFIX) between date('2020-07-01') AND CURRENT_DATE()
    AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')
    ) dau   
LEFT JOIN 
    (SELECT
        distinct parse_date("%Y%m%d", _TABLE_SUFFIX) as date,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_ios_*`
    WHERE parse_date("%Y%m%d", _TABLE_SUFFIX) between date('2020-06-20') AND CURRENT_DATE()
    AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')) l 
ON dau.user_pseudo_id = l.user_pseudo_id
AND l.date between DATE_ADD(dau.active_date, INTERVAL -7 day) AND DATE_ADD(dau.active_date, INTERVAL -1 day)
LEFT JOIN
    (SELECT
        parse_date("%Y%m%d", _TABLE_SUFFIX) as date,
        user_pseudo_id,
        count(distinct case when evt.key = 'play_count' then evt.value else null end) as game_num,
        count(case when evt.key = 'combo_type' then 1 else null end) as crush_time,
        sum(case when evt.key = 'combo_type' then cast(evt.value as int64) else 0 end) as crush_rows
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_ios_*`,
    unnest(event_params) as evt
    WHERE parse_date("%Y%m%d", _TABLE_SUFFIX) between date('2020-07-01') AND CURRENT_DATE()
    AND event_name = 'act_combo' 
    GROUP BY 1,2) game 
ON game.date = dau.active_date 
AND game.user_pseudo_id = dau.user_pseudo_id
GROUP BY 1,2,3;