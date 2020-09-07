-- CREATE TABLE `blockpuzzle-f21e1.warehouse.growth_dashboard_raw_di` (
--     date DATE OPTIONS(description="Natural date"),
--     platform STRING OPTIONS(description="app platform: Android/iOS/All"),
--     active_type STRING OPTIONS(description="user active type: New/Active/Silence"),
--     users INT64 OPTIONS(description="user numbers"),
--     start_game_users INT64 OPTIONS(description="start game user numbers"),
--     game_num FLOAT64 OPTIONS(description="total game numbers"),
--     crush_times FLOAT64 OPTIONS(description="total crush times"),
--     crush_rows FLOAT64 OPTIONS(description="total crush rows"),
--     duration_min FLOAT64 OPTIONS(description="total duration by minutes"),
--     aha_users INT64 OPTIONS(description="user numbers who reach aha moment on the first day")
--     )
-- OPTIONS (
--     description="raw sheet in growth dashboard dataset",
--     labels=[("dashboard", "analytics")]);

MERGE `blockpuzzle-f21e1.warehouse.growth_dashboard_raw_di` raw
USING
    (SELECT
        date,
        case when platform is null then 'All' else platform end as platform,
        active_type,
        users,
        start_game_users,
        game_num,
        crush_times,
        crush_rows,
        duration_min,
        aha_users
    FROM 
        (SELECT
            date,
            platform,
            active_type,
            SUM(users) as users,
            SUM(start_game_users) as start_game_users,
            SUM(game_num) as game_num,
            SUM(crush_times) as crush_times,
            SUM(crush_rows) as crush_rows,
            SUM(duration_min) as duration_min,
            SUM(aha_users) as aha_users
        FROM
            (SELECT
                "iOS" as platform,
                date,
                CASE WHEN living_days = 0 then 'new'
                    WHEN living_days != 0 and last_dau_day_diff <= 7 then 'active'
                    ELSE 'silence' END AS active_type,
                COUNT(distinct user_pseudo_id) as users,
                COUNT(distinct CASE WHEN is_active = 1 then user_pseudo_id else null end) as start_game_users,
                SUM(game_num) as game_num,
                SUM(crush_times) as crush_times,
                SUM(crush_rows) as crush_rows,
                SUM(cast(duration as float64)/60000) as duration_min,
                count(distinct case when is_aha = 1 then user_pseudo_id else null end) as aha_users
            FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*`
            WHERE date BETWEEN date_add(@run_date, interval -4 day) AND date_add(@run_date, interval -2 day)
            GROUP BY 1,2,3
            UNION ALL 
            SELECT
                "Android" as platform,
                date,
                CASE WHEN living_days = 0 then 'new'
                    WHEN living_days != 0 and last_dau_day_diff <= 7 then 'active'
                    ELSE 'silence' END AS active_type,
                COUNT(distinct user_pseudo_id) as users,
                COUNT(distinct CASE WHEN is_active = 1 then user_pseudo_id else null end) as start_game_users,
                SUM(game_num) as game_num,
                SUM(crush_times) as crush_times,
                SUM(crush_rows) as crush_rows,
                SUM(cast(duration as float64)/60000) as duration_min,
                count(distinct case when is_aha = 1 then user_pseudo_id else null end) as aha_users
            FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
            WHERE date BETWEEN date_add(@run_date, interval -4 day) AND date_add(@run_date, interval -2 day)
            GROUP BY 1,2,3)
        GROUP BY ROLLUP(date, active_type, platform)
        HAVING date is not null and active_type is not null)) new
ON raw.date = new.date
AND raw.platform = new.platform
AND raw.active_type = new.active_type
WHEN MATCHED THEN
    UPDATE SET users = new.users,
        start_game_users = new.start_game_users,
        game_num = new.game_num,
        crush_times = new.crush_times,
        crush_rows = new.crush_rows,
        duration_min = new.duration_min,
        aha_users = new.aha_users
WHEN NOT MATCHED THEN
    INSERT (date, platform, active_type, users, start_game_users, game_num, crush_times, crush_rows, duration_min, aha_users) 
        VALUES(date, platform, active_type, users, start_game_users, game_num, crush_times, crush_rows, duration_min, aha_users)