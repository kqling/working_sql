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
ON u.user_pseudo_id = r.user_pseudo_id;

-- 6月4号活跃7留和6月8号活跃7留分版本比较
SELECT
    date,
    type,
    app_version,
    COUNT(distinct user_pseudo_id) as users
FROM
    (SELECT
        u.date,
        u.app_version,
        CASE when r.user_pseudo_id is null then 'not_back' else 'retention' end as type,
        u.user_pseudo_id
    FROM
        (SELECT
            distinct CONCAT(SUBSTR(_table_suffix,0,4),'-',SUBSTR(_table_suffix,5,2),'-',SUBSTR(_table_suffix,7,2)) as date,
            app_version,
            user_pseudo_id
        FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_ios_*`
        WHERE _table_suffix = '20200604'
        AND geo.country = 'United States'
        AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')
        AND living_days != 0) u 
    LEFT JOIN
        (SELECT
            user_pseudo_id
        FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_ios_*`
        WHERE _table_suffix = '20200610'
        AND geo.country = 'United States'
        AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')) r   
    ON u.user_pseudo_id = r.user_pseudo_id)
GROUP BY 1,2,3
ORDER BY 1,2,3;

-- 卸载率
SELECT
    dau.date,
    dau.users as dau,
    ar.users as app_remove
FROM
    (SELECT
        CONCAT(SUBSTR(_table_suffix,0,4),'-',SUBSTR(_table_suffix,5,2),'-',SUBSTR(_table_suffix,7,2)) as date,
        COUNT(distinct user_pseudo_id) as users
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
    WHERE _table_suffix between '20200520' and '20200722'
    AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')
    AND geo.country = 'United States'
    GROUP BY 1) dau 
LEFT JOIN
    (SELECT
        CONCAT(SUBSTR(_table_suffix,0,4),'-',SUBSTR(_table_suffix,5,2),'-',SUBSTR(_table_suffix,7,2)) as date,
        COUNT(distinct user_pseudo_id) as users
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
    WHERE _table_suffix between '20200520' and '20200722'
    AND event_name = 'app_remove'
    AND geo.country = 'United States'
    GROUP BY 1) ar   
ON ar.date = dau.date
ORDER BY 1;


-- 新用户七天内卸载率
SELECT
    dau.date,
    COUNT(distinct dau.user_pseudo_id) as nu,
    COUNT(distinct ar.user_pseudo_id) as app_remove
FROM
    (SELECT
        distinct CONCAT(SUBSTR(_table_suffix,0,4),'-',SUBSTR(_table_suffix,5,2),'-',SUBSTR(_table_suffix,7,2)) as date,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
    WHERE _table_suffix between '20200520' and '20200722'
    AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')
    AND geo.country = 'United States'
    AND living_days = 0) dau 
LEFT JOIN
    (SELECT
        distinct user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
    WHERE _table_suffix between '20200520' and '20200728'
    AND event_name = 'app_remove'
    AND geo.country = 'United States'
    AND living_days between 0 and 6) ar   
ON ar.user_pseudo_id = dau.user_pseudo_id
GROUP BY 1
ORDER BY 1;


-- receive notification and click notification
SELECT
    dau.date,
    COUNT(distinct ar.user_pseudo_id) as receive_notification,
    COUNT(distinct cn.user_pseudo_id) as click_notification
FROM
    (SELECT
        distinct CONCAT(SUBSTR(_table_suffix,0,4),'-',SUBSTR(_table_suffix,5,2),'-',SUBSTR(_table_suffix,7,2)) as date,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
    WHERE _table_suffix between '20200520' and '20200722'
    AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')
    AND geo.country = 'United States'
    AND living_days = 0) dau 
LEFT JOIN
    (SELECT
        distinct user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
    WHERE _table_suffix between '20200520' and '20200728'
    AND event_name = 'act_receive_notification'
    AND geo.country = 'United States'
    AND living_days = 6) ar   
ON ar.user_pseudo_id = dau.user_pseudo_id
LEFT JOIN 
    (SELECT
        distinct user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
    WHERE _table_suffix between '20200520' and '20200728'
    AND event_name = 'act_click_notification'
    AND geo.country = 'United States'
    AND living_days = 6) cn
ON cn.user_pseudo_id = ar.user_pseudo_id
GROUP BY 1
ORDER BY 1;

-- 分广告平台true_show
SELECT
    nu.date,
    ad.ad_platform,
    SUM(ad.true_show) as true_show
FROM
    (SELECT
        distinct CONCAT(SUBSTR(_table_suffix,0,4),'-',SUBSTR(_table_suffix,5,2),'-',SUBSTR(_table_suffix,7,2)) as date,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
    WHERE _table_suffix between '20200520' and '20200722'
    AND geo.country = 'United States'
    AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')
    AND living_days = 0) nu
LEFT JOIN
    (SELECT
        distinct CONCAT(SUBSTR(_table_suffix,0,4),'-',SUBSTR(_table_suffix,5,2),'-',SUBSTR(_table_suffix,7,2)) as date,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
    WHERE _table_suffix between '20200520' and '20200728'
    AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')
    AND living_days = 1) r 
ON r.user_pseudo_id = nu.user_pseudo_id
AND cast(r.date as date) = DATE_ADD(cast(nu.date as date), interval 1 DAY)
LEFT JOIN 
    (SELECT
        CONCAT(SUBSTR(summary_date,0,4),'-',SUBSTR(summary_date,5,2),'-',SUBSTR(summary_date,7,2)) as date,
        user_pseudo_id,
        ad_platform,
        SUM(true_show) as true_show
    FROM `blockpuzzle-f21e1.bi_data_warehouse.adsdk_events_android_*`
    WHERE _table_suffix between '20200520' and '20200730'
    AND ad_type = 'interstitial'
    GROUP BY 1,2,3) ad
ON r.user_pseudo_id = ad.user_pseudo_id
AND cast(ad.date as date) = DATE_ADD(cast(nu.date as date), interval 1 DAY)
WHERE ad.ad_platform is not null
GROUP BY 1,2
ORDER BY 1,2



-- 新用户中d1看过vungle广告的用户和没有看过vungle广告的留存率
-- 结论：看到vungle广告的用户本来留存率就比较高，不能通过它得到留存下降的原因
SELECT
    d1.date,
    d1.see_ad,
    COUNT(distinct d1.user_pseudo_id) as users,
    COUNT(distinct r.user_pseudo_id) as retention
FROM
    (SELECT
        nu.date,
        nu.user_pseudo_id,
        CASE when r.user_pseudo_id is not null then 'retended' else 'not_back' end as retention,
        CASE when ad.user_pseudo_id is not null then 'see_ad' else 'not_see' end as see_ad
    FROM
        (SELECT
            distinct CONCAT(SUBSTR(_table_suffix,0,4),'-',SUBSTR(_table_suffix,5,2),'-',SUBSTR(_table_suffix,7,2)) as date,
            user_pseudo_id
        FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
        WHERE _table_suffix between '20200520' and '20200722'
        AND geo.country = 'United States'
        AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')
        AND living_days = 0) nu
    LEFT JOIN
        (SELECT
            distinct CONCAT(SUBSTR(_table_suffix,0,4),'-',SUBSTR(_table_suffix,5,2),'-',SUBSTR(_table_suffix,7,2)) as date,
            user_pseudo_id
        FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
        WHERE _table_suffix between '20200520' and '20200728'
        AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')
        AND living_days = 1) r 
    ON r.user_pseudo_id = nu.user_pseudo_id
    AND cast(r.date as date) = DATE_ADD(cast(nu.date as date), interval 1 DAY)
    LEFT JOIN 
        (SELECT
            distinct CONCAT(SUBSTR(summary_date,0,4),'-',SUBSTR(summary_date,5,2),'-',SUBSTR(summary_date,7,2)) as date,
            user_pseudo_id
        FROM `blockpuzzle-f21e1.bi_data_warehouse.adsdk_events_android_*`
        WHERE _table_suffix between '20200520' and '20200730'
        AND ad_type = 'interstitial'
        AND ad_platform = 'vungle') ad
    ON r.user_pseudo_id = ad.user_pseudo_id
    AND cast(ad.date as date) = DATE_ADD(cast(nu.date as date), interval 1 DAY)
    ) d1 
LEFT JOIN 
    (SELECT
        distinct CONCAT(SUBSTR(_table_suffix,0,4),'-',SUBSTR(_table_suffix,5,2),'-',SUBSTR(_table_suffix,7,2)) as date,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
    WHERE _table_suffix between '20200520' and '20200728'
    AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')
    AND living_days = 2) r 
ON r.user_pseudo_id = d1.user_pseudo_id
AND cast(r.date as date) = DATE_ADD(cast(d1.date as date), interval 2 day)
WHERE d1.retention = 'retended'
GROUP BY 1,2
ORDER BY 1,2;



