-- CREATE TABLE `blockpuzzle-f21e1.warehouse.growth_dashboard_retention_di` (
--     date DATE OPTIONS(description="Natural date"),
--     platform STRING OPTIONS(description="app platform: Android/iOS/All"),
--     active_users INT64 OPTIONS(description="active users"),
--     D1_active_retended INT64 OPTIONS(description="retended active users on D1"),
--     D1_active_retention FLOAT64 OPTIONS(description="active retention rate on D1"),
--     new_users INT64 OPTIONS(description="new users"),
--     D1_new_retended INT64 OPTIONS(description="retended new users on D1"),
--     D1_new_retention FLOAT64 OPTIONS(description="new retention rate on D1")
--     )
-- OPTIONS (
--     description="retention sheet in growth dashboard dataset",
--     labels=[("dashboard", "analytics")]);

MERGE `blockpuzzle-f21e1.warehouse.growth_dashboard_retention_di` r
USING
    (SELECT
        date,
        case when platform is null then 'All' else platform end as platform,
        active_users,
        active_retended as D1_active_retended,
        cast(active_retended as float64)/active_users as D1_active_retention,
        new_users,
        new_retended as D1_new_retended,
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
                WHERE date BETWEEN DATE_ADD(@run_date, interval -5 DAY) AND DATE_ADD(@run_date, interval -3 DAY)) u 
            LEFT JOIN
                (SELECT
                    distinct date, user_pseudo_id
                FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*`
                WHERE date BETWEEN DATE_ADD(@run_date, interval -4 DAY) AND DATE_ADD(@run_date, interval -2 DAY)) r
            ON u.user_pseudo_id = r.user_pseudo_id
            AND r.date = DATE_ADD(u.date, INTERVAL 1 DAY)
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
                WHERE date BETWEEN DATE_ADD(@run_date, interval -5 DAY) AND DATE_ADD(@run_date, interval -3 DAY)) u 
            LEFT JOIN
                (SELECT
                    distinct date, user_pseudo_id
                FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
                WHERE date BETWEEN DATE_ADD(@run_date, interval -4 DAY) AND DATE_ADD(@run_date, interval -2 DAY)) r
            ON u.user_pseudo_id = r.user_pseudo_id
            AND r.date = DATE_ADD(u.date, INTERVAL 1 DAY)
            GROUP BY 1,2)
        GROUP BY ROLLUP(date, platform)
        HAVING date is not null)) n
ON r.date = n.date
AND r.platform = n.platform
WHEN MATCHED THEN
    UPDATE SET active_users = n.active_users,
        D1_active_retended = n.D1_active_retended,
        D1_active_retention = n.D1_active_retention,
        new_users = n.new_users,
        D1_new_retended = n.D1_new_retended,
        D1_new_retention = n.D1_new_retention
WHEN NOT MATCHED THEN
    INSERT (date, platform, active_users, D1_active_retended, D1_active_retention, new_users, D1_new_retended, D1_new_retention)
        VALUES(date, platform, active_users, D1_active_retended, D1_active_retention, new_users, D1_new_retended, D1_new_retention)