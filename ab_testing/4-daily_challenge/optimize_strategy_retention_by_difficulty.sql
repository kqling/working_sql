SELECT
    date,
    puzzle_type,
    puzzle_level,
    SUM(users) as users,
    SUM(retended_users) as retended_users
FROM
    (SELECT
        u.date,
        u.puzzle_type,
        u.puzzle_level,
        COUNT(distinct u.user_pseudo_id) as users,
        COUNT(distinct r.user_pseudo_id) as retended_users
    FROM
        (SELECT
            distinct parse_date('%Y%m%d',_table_suffix) as date,
            case when type.value = '1' then '清盘' else '搜集' end as puzzle_type,
            level.value as puzzle_level,
            user_pseudo_id
        FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`,
        UNNEST(event_params) as type,
        UNNEST(event_params) as level
        WHERE _table_suffix between '20200820' and '20200830'
        AND event_name = 'scr_puzzle_play'
        and type.key = 'puzzle_type'
        AND level.key = 'puzzle_level') u
    LEFT JOIN
        (SELECT
            distinct parse_date('%Y%m%d',_table_suffix) as date,
            user_pseudo_id
        FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
        WHERE _table_suffix between '20200821' and '20200831'
        AND event_name = 'scr_puzzle_play') r
    ON u.user_pseudo_id = r.user_pseudo_id
    AND r.date = DATE_ADD(u.date, interval 1 day)
    GROUP BY 1,2,3
    UNION ALL
    SELECT
        u.date,
        u.puzzle_type,
        u.puzzle_level,
        COUNT(distinct u.user_pseudo_id) as users,
        COUNT(distinct r.user_pseudo_id) as retended_users
    FROM
        (SELECT
            distinct parse_date('%Y%m%d',_table_suffix) as date,
            case when type.value = '1' then '清盘' else '搜集' end as puzzle_type,
            level.value as puzzle_level,
            user_pseudo_id
        FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_ios_*`,
        UNNEST(event_params) as type,
        UNNEST(event_params) as level
        WHERE _table_suffix between '20200820' and '20200830'
        AND event_name = 'scr_puzzle_play'
        and type.key = 'puzzle_type'
        AND level.key = 'puzzle_level') u
    LEFT JOIN
        (SELECT
            distinct parse_date('%Y%m%d',_table_suffix) as date,
            user_pseudo_id
        FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_ios_*`
        WHERE _table_suffix between '20200821' and '20200831'
        AND event_name = 'scr_puzzle_play') r
    ON u.user_pseudo_id = r.user_pseudo_id
    AND r.date = DATE_ADD(u.date, interval 1 day)
    GROUP BY 1,2,3)
GROUP BY 1,2,3