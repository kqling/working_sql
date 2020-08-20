SELECT
    u.luid,
    create_date,
    media_source,
    crush_rows,
    crush_times,
    combo_rows,
    combo_times,
    g.games,
    prop_usage,
    best_score,
    CASE when days = 2 then 1 else 0 end as whether_retention
FROM `blockpuzzle-f21e1.infinity_karen.new_user_survey_20200820` u 
LEFT JOIN 
    (SELECT
        PARSE_DATE('%Y%m%d', _table_suffix) as create_date,
        user_pseudo_id,
        MIN(media_source) as media_source,
        MIN(up.value) as luid,
        SUM(cast(evt.value as int64)) as crush_rows,
        COUNT(*) as crush_times,
        SUM(CASE when evt.value >= '3' then cast(evt.value as int64) else null end) as combo_rows,
        COUNT(CASE when evt.value >= '3' then 1 else null end) as combo_times,
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`,
    UNNEST(event_params) as evt,
    UNNEST(user_properties) as up
    WHERE event_name = 'act_combo'
    AND evt.key = 'combo_type'
    AND up.key = 'user_id'
    AND _TABLE_SUFFIX BETWEEN "20200807" AND "20200818"
    AND living_days = 0
    GROUP BY 1,2) act
ON u.luid = act.luid
LEFT JOIN 
    (SELECT
        user_pseudo_id,
        count(distinct _table_suffix) as days
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
    WHERE event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')
    AND _TABLE_SUFFIX BETWEEN "20200807" AND "20200818"
    AND living_days <= 1
    GROUP BY 1) r
ON r.user_pseudo_id = act.user_pseudo_id
LEFT JOIN 
    (SELECT
        user_pseudo_id,
        COUNT(distinct evt.value) as games
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
    WHERE event_name = 'act_combo'
    AND evt.key = 'play_count'
    AND _TABLE_SUFFIX BETWEEN "20200807" AND "20200818"
    AND living_days = 0
    GROUP BY 1) g
ON g.user_pseudo_id = act.user_pseudo_id
LEFT JOIN 
    (SELECT
        user_pseudo_id,
        COUNT(*) as prop_usage
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
    WHERE event_name = 'scr_use_rotate'
    AND evt.key = 'act_cost_item'
    AND _TABLE_SUFFIX BETWEEN "20200807" AND "20200818"
    AND living_days = 0
    GROUP BY 1) p
ON p.user_pseudo_id = act.user_pseudo_id
LEFT JOIN 
    (SELECT
        user_pseudo_id,
        MAX(cast(evt.value as int64)) as best_score
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
    WHERE event_name = 'scr_ending'
    AND evt.key = 'best'
    AND _TABLE_SUFFIX BETWEEN "20200807" AND "20200818"
    AND living_days = 0
    GROUP BY 1) b
ON b.user_pseudo_id = act.user_pseudo_id