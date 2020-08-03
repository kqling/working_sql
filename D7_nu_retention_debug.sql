-- 新用户留存
SELECT
    u.date,
    COUNT(distinct u.user_pseudo_id) as new_users,
    COUNT(distinct r.user_pseudo_id) as retention,
    CAST(COUNT(distinct r.user_pseudo_id) as float64)/COUNT(distinct u.user_pseudo_id) as retention_rate
FROM
    (SELECT
        distinct CONCAT(SUBSTR(_table_suffix,0,4),'-',SUBSTR(_table_suffix,5,2),'-',SUBSTR(_table_suffix,7,2)) as date,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
    WHERE _table_suffix between '20200520' and '20200722'
    AND geo.country = 'United States'
    AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')
    AND living_days = 0) u 
LEFT JOIN
    (SELECT
        distinct CONCAT(SUBSTR(_table_suffix,0,4),'-',SUBSTR(_table_suffix,5,2),'-',SUBSTR(_table_suffix,7,2)) as date,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
    WHERE _table_suffix between '20200520' and '20200728'
    AND geo.country = 'United States'
    AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')
    AND living_days = 1) r   
ON cast(r.date as date) = DATE_ADD(cast(u.date as date),interval 1 DAY)
AND u.user_pseudo_id = r.user_pseudo_id
GROUP BY 1
ORDER BY 1;

-- 无新用户活跃留存
SELECT
    u.date,
    COUNT(distinct u.user_pseudo_id) as dau,
    COUNT(distinct r.user_pseudo_id) as retention,
    CAST(COUNT(distinct r.user_pseudo_id) as float64)/COUNT(distinct u.user_pseudo_id) as retention_rate
FROM
    (SELECT
        distinct CONCAT(SUBSTR(_table_suffix,0,4),'-',SUBSTR(_table_suffix,5,2),'-',SUBSTR(_table_suffix,7,2)) as date,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
    WHERE _table_suffix between '20200520' and '20200722'
    AND geo.country = 'United States'
    AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')
    AND living_days != 0) u 
LEFT JOIN
    (SELECT
        distinct CONCAT(SUBSTR(_table_suffix,0,4),'-',SUBSTR(_table_suffix,5,2),'-',SUBSTR(_table_suffix,7,2)) as date,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
    WHERE _table_suffix between '20200520' and '20200728'
    AND geo.country = 'United States'
    AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')) r   
ON cast(r.date as date) = DATE_ADD(cast(u.date as date),interval 6 DAY)
AND u.user_pseudo_id = r.user_pseudo_id
GROUP BY 1
ORDER BY 1;


-- 最活跃用户留存变化情况
SELECT
    '2020-06-09' as date,
    COUNT(distinct u.user_pseudo_id) as users,
    COUNT(distinct r.user_pseudo_id) as retention_users,
    cast(COUNT(distinct r.user_pseudo_id) as float64)/COUNT(distinct u.user_pseudo_id) as retention_rate
FROM
    (SELECT
        user_pseudo_id,
        COUNT(distinct _table_suffix) as active_days
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
    WHERE _table_suffix between '20200605' and '20200609'
    AND geo.country = 'United States'
    AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')
    AND living_days != 0
    GROUP BY 1
    HAVING COUNT(distinct _table_suffix) = 5) u   
LEFT JOIN
    (SELECT
        distinct user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
    WHERE _table_suffix = '20200610'
    AND geo.country = 'United States'
    AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')
    AND living_days != 0) r  
ON u.user_pseudo_id = r.user_pseudo_id
UNION ALL  
SELECT
    '2020-06-30' as date,
    COUNT(distinct u.user_pseudo_id) as users,
    COUNT(distinct r.user_pseudo_id) as retention_users,
    cast(COUNT(distinct r.user_pseudo_id) as float64)/COUNT(distinct u.user_pseudo_id) as retention_rate
FROM
    (SELECT
        user_pseudo_id,
        COUNT(distinct _table_suffix) as active_days
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
    WHERE _table_suffix between '20200626' and '20200630'
    AND geo.country = 'United States'
    AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')
    AND living_days != 0
    GROUP BY 1
    HAVING COUNT(distinct _table_suffix) = 5) u   
LEFT JOIN
    (SELECT
        distinct user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
    WHERE _table_suffix = '20200701'
    AND geo.country = 'United States'
    AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')
    AND living_days != 0) r  
ON u.user_pseudo_id = r.user_pseudo_id
