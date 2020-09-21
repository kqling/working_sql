SELECT
    date,
    SUM(users) as users,
    SUM(retended_users) as retended_users
FROM
    (SELECT
        u.date,
        COUNT(distinct u.user_pseudo_id) as users,
        COUNT(distinct r.user_pseudo_id) as retended_users
    FROM
        (SELECT
            distinct parse_date('%Y%m%d',_table_suffix) as date,
            user_pseudo_id
        FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
        WHERE _table_suffix between '20200820' and '20200830'
        AND event_name = 'scr_puzzle_play') u 
    LEFT JOIN
        (SELECT
            distinct parse_date('%Y%m%d',_table_suffix) as date,
            user_pseudo_id
        FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
        WHERE _table_suffix between '20200821' and '20200901'
        AND event_name = 'scr_puzzle_play') r
    ON u.user_pseudo_id = r.user_pseudo_id
    AND r.date = DATE_ADD(u.date, interval 1 day)
    GROUP BY 1
    UNION ALL
    SELECT
        u.date,
        COUNT(distinct u.user_pseudo_id) as users,
        COUNT(distinct r.user_pseudo_id) as retended_users
    FROM
        (SELECT
            distinct parse_date('%Y%m%d',_table_suffix) as date,
            user_pseudo_id
        FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_ios_*`
        WHERE _table_suffix between '20200820' and '20200830'
        AND event_name = 'scr_puzzle_play') u 
    LEFT JOIN
        (SELECT
            distinct parse_date('%Y%m%d',_table_suffix) as date,
            user_pseudo_id
        FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_ios_*`
        WHERE _table_suffix between '20200821' and '20200901'
        AND event_name = 'scr_puzzle_play') r
    ON u.user_pseudo_id = r.user_pseudo_id
    AND r.date = DATE_ADD(u.date, interval 1 day)
    GROUP BY 1)
GROUP BY 1
ORDER BY 1