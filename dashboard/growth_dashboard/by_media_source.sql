SELECT 
    case when platform is null then 'All' else platform end as platform, 
    date, 
    media_source, 
    new_users as users 
FROM 
    (SELECT 
        date, 
        media_source, 
        platform, 
        SUM(users) as new_users 
    FROM 
        (SELECT 
            'iOS' as platform, 
            date, 
            media_source, 
            COUNT(distinct user_pseudo_id) as users 
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*` 
        WHERE date between date_add(current_date(),interval -4 day) and date_add(current_date(),interval -2 day) 
        AND living_days = 0 
        GROUP BY 1,2,3 
        UNION ALL 
        SELECT 
            'Android' as platform, 
            date, 
            media_source, 
            COUNT(distinct user_pseudo_id) as users 
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*` 
        WHERE date between date_add(current_date(),interval -4 day) and date_add(current_date(),interval -2 day) 
        AND living_days = 0 
        GROUP BY 1,2,3) 
    GROUP BY ROLLUP(date, media_source, platform) 
    HAVING date is not null and media_source is not null) 
ORDER BY date, platform, media_source