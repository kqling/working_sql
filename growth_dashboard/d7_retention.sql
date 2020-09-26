SELECT
    date,
    case when platform is null then 'All' else platform end as platform,
    cast(active_retended as float64)/active_users as D1_active_retention,
    cast(new_retended as float64)/new_users as D1_new_retention
FROM
    (SELECT
        date,
        platform,
        SUM(active_users) as active_users,
        SUM(active_retended) as active_retended,
        SUM(new_users) as new_users,
        SUM(new_retended) as new_retended
    FROM
        (SELECT
            u.platform,
            u.date,
            COUNT(distinct u.user_pseudo_id) as active_users,
            COUNT(distinct r.user_pseudo_id) as active_retended,
            COUNT(distinct case when u.user_type = 'new' then u.user_pseudo_id else null end) as new_users,
            COUNT(distinct CASE when u.user_type = 'new' then r.user_pseudo_id else null end) as new_retended
        FROM
            (SELECT
                distinct 'iOS' as platform,
                date,
                CASE when living_days = 0 then 'new' else 'old' end as user_type,
                user_pseudo_id
            FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*`
            WHERE date BETWEEN DATE_ADD(CURRENT_DATE(), interval -11 DAY) AND DATE_ADD(CURRENT_DATE(), interval -9 DAY)) u 
        LEFT JOIN
            (SELECT
                distinct date, user_pseudo_id
            FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*`
            WHERE date BETWEEN DATE_ADD(CURRENT_DATE(), interval -4 DAY) AND DATE_ADD(CURRENT_DATE(), interval -2 DAY)) r
        ON u.user_pseudo_id = r.user_pseudo_id
        AND r.date = DATE_ADD(u.date, INTERVAL 7 DAY)
        GROUP BY 1,2
        UNION ALL
        SELECT
            u.platform,
            u.date,
            COUNT(distinct u.user_pseudo_id) as active_users,
            COUNT(distinct r.user_pseudo_id) as active_retended,
            COUNT(distinct case when u.user_type = 'new' then u.user_pseudo_id else null end) as new_users,
            COUNT(distinct CASE when u.user_type = 'new' then r.user_pseudo_id else null end) as new_retended
        FROM
            (SELECT
                distinct 'Android' as platform,
                date,
                CASE when living_days = 0 then 'new' else 'old' end as user_type,
                user_pseudo_id
            FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
            WHERE date BETWEEN DATE_ADD(CURRENT_DATE(), interval -11 DAY) AND DATE_ADD(CURRENT_DATE(), interval -3 DAY)) u 
        LEFT JOIN
            (SELECT
                distinct date, user_pseudo_id
            FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
            WHERE date BETWEEN DATE_ADD(CURRENT_DATE(), interval -4 DAY) AND DATE_ADD(CURRENT_DATE(), interval -2 DAY)) r
        ON u.user_pseudo_id = r.user_pseudo_id
        AND r.date = DATE_ADD(u.date, INTERVAL 7 DAY)
        GROUP BY 1,2)
    GROUP BY ROLLUP(date, platform)
    HAVING date is not null)
ORDER BY 1,2