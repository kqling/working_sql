SELECT
    date,
    ab_group,
    SUM(users) as users,
    SUM(duration_min) as duration_min,
    SUM(active_retended) as active_retended
FROM
    (SELECT
        'Android' as platform,
        u.date,
        u.ab_group,
        COUNT(distinct u.user_pseudo_id) as users,
        CAST(sum(duration) as float64)/60000 as duration_min,
        COUNT(distinct ar.user_pseudo_id) as active_retended
    FROM
        (SELECT
            date,
            CASE when abtest_tag like '%Va0%' then 'control' else 'test' end as ab_group,
            user_pseudo_id,
            SUM(duration) as duration
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
        WHERE date >= '2020-09-11'
        AND app_version >= '001009008000000'
        AND (abtest_tag like '%Va0%' or abtest_tag like '%Va1%')
        GROUP BY 1,2,3) u 
    LEFT JOIN
        (SELECT
            distinct date,
            user_pseudo_id
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
        WHERE date >= '2020-09-11'
        AND app_version >= '001009008000000'
        AND (abtest_tag like '%Va0%' or abtest_tag like '%Va1%')) ar
    ON u.user_pseudo_id = ar.user_pseudo_id
    AND ar.date = DATE_ADD(u.date, interval 1 day)
    GROUP BY 1,2,3
    UNION ALL
    SELECT
        'iOS' as platform,
        u.date,
        u.ab_group,
        COUNT(distinct u.user_pseudo_id) as users,
        CAST(sum(duration) as float64)/60000 as duration_min,
        COUNT(distinct ar.user_pseudo_id) as active_retended
    FROM
        (SELECT
            date,
            CASE when abtest_tag like '%La0%' then 'control' else 'test' end as ab_group,
            user_pseudo_id,
            SUM(duration) as duration
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*`
        WHERE date >= '2020-09-11'
        AND app_version >= '001009008000000'
        AND (abtest_tag like '%La0%' or abtest_tag like '%La1%')
        GROUP BY 1,2,3) u 
    LEFT JOIN
        (SELECT
            distinct date,
            user_pseudo_id
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*`
        WHERE date >= '2020-09-11'
        AND app_version >= '001009008000000'
        AND (abtest_tag like '%La0%' or abtest_tag like '%La1%')) ar
    ON u.user_pseudo_id = ar.user_pseudo_id
    AND ar.date = DATE_ADD(u.date, interval 1 day)
    GROUP BY 1,2,3)
GROUP BY 1,2
ORDER BY 1,2