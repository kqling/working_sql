SELECT
    date,
    platform,
    country,
    cast(active_retended as float64)/active_users as D1_active_retention,
    cast(new_retended as float64)/new_users as D1_new_retention
FROM
    (SELECT
        date,
        platform,
        country,
        SUM(active_users) as active_users,
        SUM(active_retended) as active_retended,
        SUM(new_users) as new_users,
        SUM(new_retended) as new_retended
    FROM
        (SELECT
            u.platform,
            u.date,
            u.country,
            COUNT(distinct u.user_pseudo_id) as active_users,
            COUNT(distinct r.user_pseudo_id) as active_retended,
            COUNT(distinct case when u.user_type = 'new' then u.user_pseudo_id else null end) as new_users,
            COUNT(distinct CASE when u.user_type = 'new' then r.user_pseudo_id else null end) as new_retended
        FROM
            (SELECT
                distinct 'iOS' as platform,
                date,
                CASE when living_days = 0 then 'new' else 'old' end as user_type,
                case when country in ('United States','United Kingdom','Germany','France','Spain','Russia','Japan','Mexico','Brazil') then country else 'other' end as country,
                user_pseudo_id
            FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*`
            WHERE date BETWEEN DATE_ADD(CURRENT_DATE(), INTERVAL -5 DAY) AND DATE_ADD(CURRENT_DATE(), INTERVAL -3 DAY)) u 
        LEFT JOIN
            (SELECT
                distinct date, user_pseudo_id
            FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*`
            WHERE date BETWEEN DATE_ADD(CURRENT_DATE(), INTERVAL -4 DAY) AND DATE_ADD(CURRENT_DATE(), INTERVAL -2 DAY)) r
        ON u.user_pseudo_id = r.user_pseudo_id
        AND r.date = DATE_ADD(u.date, INTERVAL 1 DAY)
        GROUP BY 1,2,3
        UNION ALL
        SELECT
            u.platform,
            u.date,
            u.country,
            COUNT(distinct u.user_pseudo_id) as active_users,
            COUNT(distinct r.user_pseudo_id) as active_retended,
            COUNT(distinct case when u.user_type = 'new' then u.user_pseudo_id else null end) as new_users,
            COUNT(distinct CASE when u.user_type = 'new' then r.user_pseudo_id else null end) as new_retended
        FROM
            (SELECT
                distinct 'Android' as platform,
                date,
                case when country in ('United States','United Kingdom','Germany','France','Spain','Russia','Japan','Mexico','Brazil') then country else 'other' end as country,
                CASE when living_days = 0 then 'new' else 'old' end as user_type,
                user_pseudo_id
            FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
            WHERE date BETWEEN DATE_ADD(CURRENT_DATE(), INTERVAL -5 DAY) AND DATE_ADD(CURRENT_DATE(), INTERVAL -3 DAY)) u 
        LEFT JOIN
            (SELECT
                distinct date, user_pseudo_id
            FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
            WHERE date BETWEEN DATE_ADD(CURRENT_DATE(), INTERVAL -4 DAY) AND DATE_ADD(CURRENT_DATE(), INTERVAL -2 DAY)) r
        ON u.user_pseudo_id = r.user_pseudo_id
        AND r.date = DATE_ADD(u.date, INTERVAL 1 DAY)
        GROUP BY 1,2,3)
    GROUP BY date, platform,3)
order by 1,2,3