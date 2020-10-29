SELECT
    date,
    ab_group,
    SUM(users) as users,
    SUM(duration_min) as duration_min,
    SUM(game_num) as game_num,
    SUM(is_removed) as is_removed,
    SUM(is_active) as is_active,
    SUM(D1_retended_users) as D1_retended_users,
    SUM(D5_retended_users) as D5_retended_users
FROM
    (SELECT
        u.date,
        u.ab_group,
        COUNT(distinct u.user_pseudo_id) as users,
        cast(SUM(duration) as float64)/60000 as duration_min,
        SUM(game_num) as game_num,
        SUM(is_removed) as is_removed,
        SUM(is_active) as is_active,
        COUNT(distinct r.user_pseudo_id) as D1_retended_users,
        COUNT(distinct r5.user_pseudo_id) as D5_retended_users,
    FROM
        (SELECT
            date,
            CASE when abtest_tag like '%Kb0%' then 'control' 
                 when abtest_tag like '%Kb1%' then 'test1' 
                 when abtest_tag like '%Kb2%' then 'test2' end as ab_group,
            user_pseudo_id,
            SUM(duration) as duration,
            SUM(game_num) as game_num,
            case when SUM(is_removed) >= 1 then 1 else 0 end as is_removed,
            case when SUM(is_active) >= 1 then 1 else 0 end as is_active
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.aPalytics_dm_action_userPrimaryMetric_di_*`
        WHERE date >= '2020-10-17'
        AND app_version >= '001012000000000'
        AND (abtest_tag like '%Kb0%' or abtest_tag like '%Kb1%' or abtest_tag like '%Kb2%')
        GROUP BY 1,2,3) u
    LEFT JOIN
        (SELECT
            distinct date,
            user_pseudo_id
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.aPalytics_dm_action_userPrimaryMetric_di_*`
        WHERE date >= '2020-10-17'
        AND app_version >= '001012000000000'
        AND (abtest_tag like '%Kb0%' or abtest_tag like '%Kb1%' or abtest_tag like '%Kb2%')) r
    ON r.date = DATE_ADD(u.date, interval 1 day)
    AND r.user_pseudo_id = u.user_pseudo_id
    LEFT JOIN
        (SELECT
            distinct date,
            user_pseudo_id
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.aPalytics_dm_action_userPrimaryMetric_di_*`
        WHERE date >= '2020-10-17'
        AND app_version >= '001012000000000'
        AND (abtest_tag like '%Kb0%' or abtest_tag like '%Kb1%' or abtest_tag like '%Kb2%')) r5
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
        SUM(is_removed) as is_removed,
        SUM(is_active) as is_active,
        COUNT(distinct r.user_pseudo_id) as D1_retended_users,
        COUNT(distinct r5.user_pseudo_id) as D5_retended_users,
    FROM
        (SELECT
            date,
            CASE when abtest_tag like '%Pa0%' then 'control' 
                 when abtest_tag like '%Pa1%' then 'test1' 
                 when abtest_tag like '%Pa2%' then 'test2' end as ab_group,
            user_pseudo_id,
            SUM(duration) as duration,
            SUM(game_num) as game_num,
            case when SUM(is_removed) >= 1 then 1 else 0 end as is_removed,
            case when SUM(is_active) >= 1 then 1 else 0 end as is_active
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.aPalytics_dm_action_userPrimaryMetric_di_*`
        WHERE date >= '2020-10-17'
        AND app_version >= '001012000000000'
        AND (abtest_tag like '%Pa0%' or abtest_tag like '%Pa1%' or abtest_tag like '%Pa2%')
        GROUP BY 1,2,3) u
    LEFT JOIN
        (SELECT
            distinct date,
            user_pseudo_id
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.aPalytics_dm_action_userPrimaryMetric_di_*`
        WHERE date >= '2020-10-17'
        AND app_version >= '001012000000000'
        AND (abtest_tag like '%Pa0%' or abtest_tag like '%Pa1%' or abtest_tag like '%Pa2%')) r
    ON r.date = DATE_ADD(u.date, interval 1 day)
    AND r.user_pseudo_id = u.user_pseudo_id
    LEFT JOIN
        (SELECT
            distinct date,
            user_pseudo_id
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.aPalytics_dm_action_userPrimaryMetric_di_*`
        WHERE date >= '2020-10-17'
        AND app_version >= '001012000000000'
        AND (abtest_tag like '%Pa0%' or abtest_tag like '%Pa1%' or abtest_tag like '%Pa2%')) r5
    ON r5.date = DATE_ADD(u.date, interval 5 day)
    AND r5.user_pseudo_id = u.user_pseudo_id
    GROUP BY 1,2)
GROUP BY 1,2
ORDER BY 1,2