SELECT
    date,
    puzzle_type,
    puzzle_level,
    SUM(start_users) as start_users,
    SUM(start_times) as start_times,
    SUM(win_users) as win_users,
    SUM(win_times) as win_times
FROM
    (SELECT
        start.date,
        start.puzzle_type,
        start.puzzle_level,
        start.users as start_users,
        start.start_times as start_times,
        e.win_users,
        e.win_times
    FROM
        (SELECT
            parse_date('%Y%m%d',_table_suffix) as date,
            case when type.value = '1' then '清盘' else '搜集' end as puzzle_type,
            level.value as puzzle_level,
            COUNT(distinct user_pseudo_id) as users,
            COUNT(*) as start_times
        FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`,
        UNNEST(event_params) as type,
        UNNEST(event_params) as level
        WHERE _table_suffix between '20200820' and '20200831'
        AND event_name = 'scr_puzzle_play'
        and type.key = 'puzzle_type'
        AND level.key = 'puzzle_level'
        GROUP BY 1,2,3) start
    LEFT JOIN
        (SELECT
            parse_date('%Y%m%d',_table_suffix) as date,
            case when puzzle.value = '1' then '清盘' else '搜集' end as puzzle_type,
            level.value as puzzle_level,
            COUNT(distinct user_pseudo_id) as win_users,
            COUNT(*) as win_times
        FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`,
        UNNEST(event_params) as puzzle,
        UNNEST(event_params) as level,
        UNNEST(event_params) as result
        WHERE _table_suffix between '20200820' and '20200831'
        AND event_name = 'scr_puzzle_ending'
        and puzzle.key = 'puzzle_type'
        AND result.key = 'result'
        AND level.key = 'puzzle_level'
        AND result.value = 'win'
        GROUP BY 1,2,3) e
    ON start.date = e.date
    AND start.puzzle_type = e.puzzle_type
    AND start.puzzle_level = e.puzzle_level
    UNION ALL
    SELECT
        start.date,
        start.puzzle_type,
        start.puzzle_level,
        start.users as start_users,
        start.start_times as start_times,
        e.win_users,
        e.win_times
    FROM
        (SELECT
            parse_date('%Y%m%d',_table_suffix) as date,
            case when evt.value = '1' then '清盘' else '搜集' end as puzzle_type,
            level.value as puzzle_level,
            COUNT(distinct user_pseudo_id) as users,
            COUNT(*) as start_times
        FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_ios_*`,
        UNNEST(event_params) as evt,
        UNNEST(event_params) as level
        WHERE _table_suffix between '20200820' and '20200831'
        AND event_name = 'scr_puzzle_play'
        and evt.key = 'puzzle_type'
        AND level.key = 'puzzle_level'
        GROUP BY 1,2,3) start
    LEFT JOIN
        (SELECT
            parse_date('%Y%m%d',_table_suffix) as date,
            case when puzzle.value = '1' then '清盘' else '搜集' end as puzzle_type,
            level.value as puzzle_level,
            COUNT(distinct user_pseudo_id) as win_users,
            COUNT(*) as win_times
        FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_ios_*`,
        UNNEST(event_params) as puzzle,
        UNNEST(event_params) as level,
        UNNEST(event_params) as result
        WHERE _table_suffix between '20200820' and '20200831'
        AND event_name = 'scr_puzzle_ending'
        and puzzle.key = 'puzzle_type'
        AND result.key = 'result'
        AND result.value = 'win'
        AND level.key = 'puzzle_level'
        GROUP BY 1,2,3) e
    ON start.date = e.date
    AND start.puzzle_type = e.puzzle_type
    AND start.puzzle_level = e.puzzle_level)
GROUP BY 1,2,3
ORDER BY 1,2,3