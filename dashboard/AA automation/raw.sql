SELECT 
    u.date, 
    u.ab_group, 
    COUNT(distinct u.user_pseudo_id) as users, 
    cast(SUM(duration) as float64)/60000 as duration_min, 
    SUM(game_num) as game_num, 
    SUM(rewarded_show) as rewarded_show, 
    SUM(inter_show) as inter_show, 
    COUNT(distinct r.user_pseudo_id) as D1_retended_users, 
    COUNT(distinct r5.user_pseudo_id) as D5_retended_users, 
    COUNT(distinct case when u.living_days = 0 then u.user_pseudo_id else null end) as new_users, 
    COUNT(distinct CASE when u.living_days = 0 then r.user_pseudo_id else null end) as D1_new_retended, 
    COUNT(distinct CASE when u.living_days = 0 then r5.user_pseudo_id else null end) as D5_new_retended 
FROM 
    (SELECT 
        date, 
        CASE when abtest_tag like '%%' then 'control' when abtest_tag like '%%' then 'test' end as ab_group, 
        user_pseudo_id, 
        living_days, 
        SUM(duration) as duration, 
        SUM(game_num) as game_num, 
        SUM(inter_show) as inter_show, 
        SUM(rewarded_show) as rewarded_show 
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*` 
    WHERE date between '' and '' 
    AND (abtest_tag like '%%' or abtest_tag like '%%') 
        GROUP BY 1,2,3,4) u 
LEFT JOIN 
    (SELECT 
        distinct date, 
        user_pseudo_id 
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*` 
    WHERE date between '' and '' 
    AND (abtest_tag like '%%' or abtest_tag like '%%')) r 
ON r.date = DATE_ADD(u.date, interval 1 day) 
AND r.user_pseudo_id = u.user_pseudo_id 
LEFT JOIN 
    (SELECT 
        distinct date, 
        user_pseudo_id 
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*` 
    WHERE date between '' and '' 
    AND (abtest_tag like '%%' or abtest_tag like '%%')) r5 
ON r5.date = DATE_ADD(u.date, interval 5 day) 
AND r5.user_pseudo_id = u.user_pseudo_id 
GROUP BY 1,2 
ORDER BY 1,2