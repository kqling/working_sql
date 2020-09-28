SELECT
    date,
    ab_group,
    SUM(users) as users,
    SUM(duration_min) as duration_min,
    SUM(game_num) as game_num,
    SUM(inter_show) as inter_show,
    SUM(rewarded_show) as rewarded_show,
    SUM(D1_retended_users) as D1_retended_users,
    SUM(D5_retended_users) as D5_retended_users
FROM
    (SELECT
        u.date,
        u.ab_group,
        COUNT(distinct u.user_pseudo_id) as users,
        cast(SUM(duration) as float64)/60000 as duration_min,
        SUM(game_num) as game_num,
        SUM(rewarded_show) as rewarded_show,
        SUM(inter_show) as inter_show,
        COUNT(distinct r.user_pseudo_id) as D1_retended_users,
        COUNT(distinct r5.user_pseudo_id) as D5_retended_users,
    FROM
        (SELECT
            date,
            CASE when abtest_tag like '%Ix0%' then 'control' when abtest_tag like '%Ix1%' then 'test' end as ab_group,
            user_pseudo_id,
            SUM(duration) as duration,
            SUM(game_num) as game_num,
            SUM(inter_show) as inter_show,
            SUM(rewarded_show) as rewarded_show
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
        WHERE date >= '2020-09-17'
        AND app_version >= '001009009000000'
        AND (abtest_tag like '%Ix0%' or abtest_tag like '%Ix1%')
        AND living_days = 0
        GROUP BY 1,2,3) u
    LEFT JOIN
        (SELECT
            distinct date,
            user_pseudo_id
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
        WHERE date >= '2020-09-17'
        AND app_version >= '001009009000000'
        AND (abtest_tag like '%Ix0%' or abtest_tag like '%Ix1%')
        AND living_days = 1) r
    ON r.date = DATE_ADD(u.date, interval 1 day)
    AND r.user_pseudo_id = u.user_pseudo_id
    LEFT JOIN
        (SELECT
            distinct date,
            user_pseudo_id
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
        WHERE date >= '2020-09-17'
        AND app_version >= '001009009000000'
        AND (abtest_tag like '%Ix0%' or abtest_tag like '%Ix1%')
        AND living_days = 5) r5
    ON r5.date = DATE_ADD(u.date, interval 5 day)
    AND r5.user_pseudo_id = u.user_pseudo_id
    GROUP BY 1,2
    UNION ALL
    SELECT
        u.date,
        u.ab_group,
        COUNT(distinct u.user_pseudo_id) as users,
        cast(SUM(duration) as float64)/60000 as duration_min,
        SUM(game_num) as game_num,
        SUM(inter_show) as inter_show,
        SUM(rewarded_show) as rewarded_show,
        COUNT(distinct r.user_pseudo_id) as D1_retended_users,
        COUNT(distinct r5.user_pseudo_id) as D5_retended_users,
    FROM
        (SELECT
            date,
            CASE when abtest_tag like '%Yv0%' then 'control' when abtest_tag like '%Yv1%' then 'test' end as ab_group,
            user_pseudo_id,
            SUM(duration) as duration,
            SUM(game_num) as game_num,
            SUM(inter_show) as inter_show,
            SUM(rewarded_show) as rewarded_show
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*`
        WHERE date >= '2020-09-17'
        AND app_version >= '001009009000000'
        AND (abtest_tag like '%Yv0%' or abtest_tag like '%Yv1%')
        AND living_days = 0
        GROUP BY 1,2,3) u
    LEFT JOIN
        (SELECT
            distinct date,
            user_pseudo_id
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*`
        WHERE date >= '2020-09-17'
        AND app_version >= '001009009000000'
        AND (abtest_tag like '%Yv0%' or abtest_tag like '%Yv1%')
        AND living_days = 1) r
    ON r.date = DATE_ADD(u.date, interval 1 day)
    AND r.user_pseudo_id = u.user_pseudo_id
    LEFT JOIN
        (SELECT
            distinct date,
            user_pseudo_id
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*`
        WHERE date >= '2020-09-17'
        AND app_version >= '001009009000000'
        AND (abtest_tag like '%Yv0%' or abtest_tag like '%Yv1%')
        AND living_days = 5) r5
    ON r5.date = DATE_ADD(u.date, interval 5 day)
    AND r5.user_pseudo_id = u.user_pseudo_id
    GROUP BY 1,2)
GROUP BY 1,2
ORDER BY 1,2