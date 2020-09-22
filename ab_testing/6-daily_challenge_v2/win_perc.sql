SELECT
    date,
    ab_group,
    -- difficulty,
    SUM(start_users) as start_users,
    SUM(start_times) as start_times,
    SUM(win_users) as win_users,
    SUM(win_times) as win_times
FROM
    (SELECT
        start.date,
        start.ab_group,
        -- CASE when start.puzzle_type = '清盘' and start.puzzle_level = '3' then 'easy'
        --      when start.puzzle_type = '清盘' or start.puzzle_level in ('1','3') then 'medium'
        --      else 'diffucult' end as difficulty,
        SUM(start.users) as start_users,
        SUM(start.start_times) as start_times,
        SUM(e.win_users) as win_users,
        SUM(e.win_times) as win_times
    FROM
        (SELECT
            parse_date('%Y%m%d',_table_suffix) as date,
            CASE when abtest_tag like '%Va0%' then 'control' else 'test' end as ab_group,
            -- case when type.value.string_value = '1' then '清盘' else '搜集' end as puzzle_type,
            -- level.value.string_value as puzzle_level,
            COUNT(distinct user_pseudo_id) as users,
            COUNT(*) as start_times
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.fact_ods_action_basicEvents_di_*`,
        UNNEST(event_params) as type,
        UNNEST(event_params) as level
        WHERE _table_suffix >= '20200911'
        AND event_name = 'scr_puzzle_play'
        and type.key = 'puzzle_type'
        AND level.key = 'puzzle_level'
        AND (abtest_tag like '%Va0%' or abtest_tag like '%Va1%')
        AND app_version >= '001009008000000'
        GROUP BY 1,2) start
    LEFT JOIN
        (SELECT
            parse_date('%Y%m%d',_table_suffix) as date,
            CASE when abtest_tag like '%Va0%' then 'control' else 'test' end as ab_group,
            -- case when puzzle.value.string_value = '1' then '清盘' else '搜集' end as puzzle_type,
            -- level.value.string_value as puzzle_level,
            COUNT(distinct user_pseudo_id) as win_users,
            COUNT(*) as win_times
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.fact_ods_action_basicEvents_di_*`,
        UNNEST(event_params) as puzzle,
        UNNEST(event_params) as level,
        UNNEST(event_params) as result
        WHERE _table_suffix >= '20200911'
        AND event_name = 'scr_puzzle_ending'
        and puzzle.key = 'puzzle_type'
        AND result.key = 'result'
        AND level.key = 'puzzle_level'
        AND result.value.string_value = 'win'
        AND (abtest_tag like '%Va0%' or abtest_tag like '%Va1%')
        AND app_version >= '001009008000000'
        GROUP BY 1,2) e
    ON start.date = e.date
    -- AND start.puzzle_type = e.puzzle_type
    -- AND start.puzzle_level = e.puzzle_level
    AND start.ab_group = e.ab_group
    GROUP BY 1,2
    UNION ALL
    SELECT
        start.date,
        start.ab_group,
        -- CASE when start.puzzle_type = '清盘' and start.puzzle_level = '3' then 'easy'
        --      when start.puzzle_type = '清盘' or start.puzzle_level in ('1','3') then 'medium'
        --      else 'diffucult' end as difficulty,
        SUM(start.users) as start_users,
        SUM(start.start_times) as start_times,
        SUM(e.win_users) as win_users,
        SUM(e.win_times) as win_times
    FROM
        (SELECT
            parse_date('%Y%m%d',_table_suffix) as date,
            CASE when abtest_tag like '%La0%' then 'control' else 'test' end as ab_group,
            -- case when type.value.string_value = '1' then '清盘' else '搜集' end as puzzle_type,
            -- level.value.string_value as puzzle_level,
            COUNT(distinct user_pseudo_id) as users,
            COUNT(*) as start_times
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.fact_ods_action_basicEvents_di_*`,
        UNNEST(event_params) as type,
        UNNEST(event_params) as level
        WHERE _table_suffix >= '20200911'
        AND event_name = 'scr_puzzle_play'
        and type.key = 'puzzle_type'
        AND level.key = 'puzzle_level'
        AND (abtest_tag like '%La0%' or abtest_tag like '%La1%')
        and app_version >= '001009008000000'
        GROUP BY 1,2) start
    LEFT JOIN
        (SELECT
            parse_date('%Y%m%d',_table_suffix) as date,
            CASE when abtest_tag like '%La0%' then 'control' else 'test' end as ab_group,
            -- case when puzzle.value.string_value = '1' then '清盘' else '搜集' end as puzzle_type,
            -- level.value.string_value as puzzle_level,
            COUNT(distinct user_pseudo_id) as win_users,
            COUNT(*) as win_times
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.fact_ods_action_basicEvents_di_*`,
        UNNEST(event_params) as puzzle,
        UNNEST(event_params) as level,
        UNNEST(event_params) as result
        WHERE _table_suffix >= '20200911'
        AND event_name = 'scr_puzzle_ending'
        and puzzle.key = 'puzzle_type'
        AND result.key = 'result'
        AND level.key = 'puzzle_level'
        AND result.value.string_value = 'win'
        AND (abtest_tag like '%La0%' or abtest_tag like '%La1%')
        AND app_version >= '001009008000000'
        GROUP BY 1,2) e
    ON start.date = e.date
    -- AND start.puzzle_type = e.puzzle_type
    -- AND start.puzzle_level = e.puzzle_level
    AND start.ab_group = e.ab_group
    GROUP BY 1,2)
GROUP BY 1,2
ORDER BY 1,2