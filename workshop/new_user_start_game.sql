SELECT
    nu.platform,
    nu.date,
    count(distinct crush_one_row.user_pseudo_id) as nu_start_game
FROM 
    (SELECT
        distinct 'Android' as platform,
        format_date('%Y-%m-%d', parse_date("%Y%m%d", _TABLE_SUFFIX)) as date,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
    WHERE parse_date("%Y%m%d", _TABLE_SUFFIX) between date('2020-07-01') AND CURRENT_DATE()
    AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')
    AND living_days = 0) nu
INNER JOIN 
    (SELECT
        distinct format_date('%Y-%m-%d', parse_date("%Y%m%d", _TABLE_SUFFIX)) as date,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
    WHERE parse_date("%Y%m%d", _TABLE_SUFFIX) between date('2020-07-01') AND CURRENT_DATE()
    AND event_name = 'act_new_game' 
    AND living_days = 0) new_game 
ON new_game.date = nu.date
AND new_game.user_pseudo_id = nu.user_pseudo_id
INNER JOIN 
    (SELECT
        distinct format_date('%Y-%m-%d', parse_date("%Y%m%d", _TABLE_SUFFIX)) as date,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
    WHERE parse_date("%Y%m%d", _TABLE_SUFFIX) between date('2020-07-01') AND CURRENT_DATE()
    AND event_name = 'act_combo' 
    AND living_days = 0) crush_one_row 
ON crush_one_row.date = new_game.date 
AND crush_one_row.user_pseudo_id = new_game.user_pseudo_id
GROUP BY 1,2
UNION ALL
SELECT
    nu.platform,
    nu.date,
    count(distinct crush_one_row.user_pseudo_id) as nu_start_game
FROM 
    (SELECT
        distinct 'iOS' as platform,
        format_date('%Y-%m-%d', parse_date("%Y%m%d", _TABLE_SUFFIX)) as date,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_ios_*`
    WHERE parse_date("%Y%m%d", _TABLE_SUFFIX) between date('2020-07-01') AND CURRENT_DATE()
    AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')
    AND living_days = 0) nu
INNER JOIN 
    (SELECT
        distinct format_date('%Y-%m-%d', parse_date("%Y%m%d", _TABLE_SUFFIX)) as date,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_ios_*`
    WHERE parse_date("%Y%m%d", _TABLE_SUFFIX) between date('2020-07-01') AND CURRENT_DATE()
    AND event_name = 'act_new_game' 
    AND living_days = 0) new_game 
ON new_game.date = nu.date
AND new_game.user_pseudo_id = nu.user_pseudo_id
INNER JOIN 
    (SELECT
        distinct format_date('%Y-%m-%d', parse_date("%Y%m%d", _TABLE_SUFFIX)) as date,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_ios_*`
    WHERE parse_date("%Y%m%d", _TABLE_SUFFIX) between date('2020-07-01') AND CURRENT_DATE()
    AND event_name = 'act_combo' 
    AND living_days = 0) crush_one_row 
ON crush_one_row.date = new_game.date 
AND crush_one_row.user_pseudo_id = new_game.user_pseudo_id
GROUP BY 1,2
ORDER BY 1,2