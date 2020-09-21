SELECT
    date,
    SUM(unlock_user) as unlock_user,
    SUM(start_user) as start_user,
    SUM(end_user) as end_user,
    SUM(unlock_puzzles) as unlock_puzzles,
    SUM(start_puzzles) as start_puzzles,
    SUM(end_puzzles) as end_puzzles
FROM
    (SELECT
        parse_date('%Y%m%d',_table_suffix) as date,
        COUNT(distinct CASE when event_name = 'scr_start_puzzle' then user_pseudo_id else null end) as unlock_user,
        COUNT(distinct CASE when event_name = 'scr_puzzle_play' then user_pseudo_id else null end) as start_user,
        COUNT(distinct CASE when event_name = 'scr_puzzle_ending' then user_pseudo_id else null end) as end_user,
        COUNT(distinct CASE when event_name = 'scr_start_puzzle' then CONCAT(user_pseudo_id,evt.value) else null end) as unlock_puzzles,
        COUNT(distinct CASE when event_name = 'scr_puzzle_play' then CONCAT(user_pseudo_id,evt.value) else null end) as start_puzzles,
        COUNT(distinct CASE when event_name = 'scr_puzzle_ending' then CONCAT(user_pseudo_id,evt.value) else null end) as end_puzzles
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`,
    UNNEST(event_params) as evt
    WHERE _table_suffix between '20200820' and '20200831'
    AND event_name in ('scr_start_puzzle','scr_puzzle_play','scr_puzzle_ending')
    and evt.key = 'puzzle_id'
    GROUP BY 1
    UNION ALL
    SELECT
        parse_date('%Y%m%d',_table_suffix) as date,
        COUNT(distinct CASE when event_name = 'scr_start_puzzle' then user_pseudo_id else null end) as unlock_user,
        COUNT(distinct CASE when event_name = 'scr_puzzle_play' then user_pseudo_id else null end) as start_user,
        COUNT(distinct CASE when event_name = 'scr_puzzle_ending' then user_pseudo_id else null end) as end_user,
        COUNT(distinct CASE when event_name = 'scr_start_puzzle' then CONCAT(user_pseudo_id,evt.value) else null end) as unlock_puzzles,
        COUNT(distinct CASE when event_name = 'scr_puzzle_play' then CONCAT(user_pseudo_id,evt.value) else null end) as start_puzzles,
        COUNT(distinct CASE when event_name = 'scr_puzzle_ending' then CONCAT(user_pseudo_id,evt.value) else null end) as end_puzzles
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_ios_*`,
    UNNEST(event_params) as evt
    WHERE _table_suffix between '20200820' and '20200831'
    AND event_name in ('scr_start_puzzle','scr_puzzle_play','scr_puzzle_ending')
    and evt.key = 'puzzle_id'
    GROUP BY 1)
GROUP BY 1
ORDER BY 1