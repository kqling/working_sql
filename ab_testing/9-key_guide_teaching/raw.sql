SELECT
    date,
    ab_group,
    SUM(users) as users,
    SUM(duration_min) as duration_min,
    SUM(game_num) as game_num,
    SUM(second_game_users) as second_game_users,
    SUM(third_game_users) as third_game_users,
    SUM(D1_retended_users) as D1_retended_users
FROM
    (SELECT
        u.date,
        u.ab_group,
        COUNT(distinct u.user_pseudo_id) as users,
        cast(SUM(duration) as float64)/60000 as duration_min,
        COUNT(distinct case when game_num >= 2 then u.user_pseudo_id else null end) as second_game_users,
        COUNT(distinct case when game_num >= 3 then u.user_pseudo_id else null end) as third_game_users,
        SUM(game_num) as game_num,
        COUNT(distinct r.user_pseudo_id) as D1_retended_users
    FROM
        (SELECT
            date,
            CASE when abtest_tag like '%Mb0%' then 'control' 
                 when abtest_tag like '%Mb1%' then 'test' end as ab_group,
            user_pseudo_id,
            SUM(duration) as duration,
            SUM(game_num) as game_num
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
        WHERE date >= '2020-09-29'
        AND app_version >= '001010000000000'
        AND abtest_tag like '%Ix1%'
        AND (abtest_tag like '%Mb0%' or abtest_tag like '%Mb1%')
        AND living_days = 0
        GROUP BY 1,2,3) u
    LEFT JOIN
        (SELECT
            distinct date,
            user_pseudo_id
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
        WHERE date >= '2020-09-29'
        AND app_version >= '001010000000000'
        AND abtest_tag like '%Ix1%'
        AND (abtest_tag like '%Mb0%' or abtest_tag like '%Mb1%')
        AND living_days = 1) r
    ON r.date = DATE_ADD(u.date, interval 1 day)
    AND r.user_pseudo_id = u.user_pseudo_id
    GROUP BY 1,2
    UNION ALL
    SELECT
        u.date,
        u.ab_group,
        COUNT(distinct u.user_pseudo_id) as users,
        cast(SUM(duration) as float64)/60000 as duration_min,
        COUNT(distinct case when game_num >= 2 then u.user_pseudo_id else null end) as second_game_users,
        COUNT(distinct case when game_num >= 3 then u.user_pseudo_id else null end) as third_game_users,
        SUM(game_num) as game_num,
        COUNT(distinct r.user_pseudo_id) as D1_retended_users
    FROM
        (SELECT
            date,
            CASE when abtest_tag like '%Aa0%' then 'control' 
                 when abtest_tag like '%Aa1%' then 'test' end as ab_group,
            user_pseudo_id,
            SUM(duration) as duration,
            SUM(game_num) as game_num
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*`
        WHERE date >= '2020-09-29'
        AND app_version >= '001010000000000'
        AND abtest_tag like '%Yv1%'
        AND (abtest_tag like '%Aa0%' or abtest_tag like '%Aa1%')
        AND living_days = 0
        GROUP BY 1,2,3) u
    LEFT JOIN
        (SELECT
            distinct date,
            user_pseudo_id
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*`
        WHERE date >= '2020-09-29'
        AND app_version >= '001010000000000'
        AND abtest_tag like '%Yv1%'
        AND (abtest_tag like '%Aa0%' or abtest_tag like '%Aa1%')
        AND living_days = 1) r
    ON r.date = DATE_ADD(u.date, interval 1 day)
    AND r.user_pseudo_id = u.user_pseudo_id
    GROUP BY 1,2)
GROUP BY 1,2
ORDER BY 1,2