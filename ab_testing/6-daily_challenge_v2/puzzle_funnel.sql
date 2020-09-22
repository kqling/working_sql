SELECT
    date,
    ab_group,
    SUM(unlock_user) as unlock_user,
    SUM(start_user) as start_user,
    SUM(start_puzzles) as start_puzzles
FROM
    (SELECT
        parse_date('%Y%m%d',_table_suffix) as date,
        CASE when abtest_tag like '%Va0%' then 'control' else 'test' end as ab_group,
        COUNT(distinct CASE when event_name = 'scr_start_puzzle' then user_pseudo_id else null end) as unlock_user,
        COUNT(distinct CASE when event_name = 'scr_puzzle_play' then user_pseudo_id else null end) as start_user,
        COUNT(distinct CASE when event_name = 'scr_puzzle_play' then CONCAT(user_pseudo_id,evt.value.string_value) else null end) as start_puzzles
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.fact_ods_action_basicEvents_di_*`,
    UNNEST(event_params) as evt
    WHERE _table_suffix >= '20200911'
    AND event_name in ('scr_start_puzzle','scr_puzzle_play','scr_puzzle_ending')
    and evt.key = 'puzzle_id'
    and (abtest_tag like '%Va0%' or abtest_tag like '%Va1%')
    GROUP BY 1,2
    UNION ALL
    SELECT
        parse_date('%Y%m%d',_table_suffix) as date,
        CASE when abtest_tag like '%La0%' then 'control' else 'test' end as ab_group,
        COUNT(distinct CASE when event_name = 'scr_start_puzzle' then user_pseudo_id else null end) as unlock_user,
        COUNT(distinct CASE when event_name = 'scr_puzzle_play' then user_pseudo_id else null end) as start_user,
        COUNT(distinct CASE when event_name = 'scr_puzzle_play' then CONCAT(user_pseudo_id,evt.value.string_value) else null end) as start_puzzles
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.fact_ods_action_basicEvents_di_*`,
    UNNEST(event_params) as evt
    WHERE _table_suffix >= '20200911'
    AND event_name in ('scr_start_puzzle','scr_puzzle_play','scr_puzzle_ending')
    and evt.key = 'puzzle_id'
    and (abtest_tag like '%La0%' or abtest_tag like '%La1%')
    GROUP BY 1,2)
GROUP BY 1,2
ORDER BY 1,2