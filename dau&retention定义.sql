-- 两种口径的DAU数量check
SELECT
    CASE when splash.date is not null then splash.date else total.date end as date,
    COUNT(distinct splash.user_pseudo_id) as custom_dau,
    COUNT(distinct total.user_pseudo_id) as user_engagement_dau,
    COUNT(distinct CASE when total.user_pseudo_id is null then splash.user_pseudo_id else null end) as custom_not_user_engagement,
    COUNT(distinct CASE when splash.user_pseudo_id is null then total.user_pseudo_id else null end) as user_engagement_not_custom
FROM 
    (SELECT
        distinct concat(substr(_table_suffix,0,4),'-',substr(_table_suffix,5,2),'-',substr(_table_suffix,7,2)) as date,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`,
    UNNEST(event_params) as evt
    WHERE _table_suffix between '20200701' and '20200707'
    AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')) splash
FULL OUTER JOIN
    (SELECT
        distinct concat(substr(_table_suffix,0,4),'-',substr(_table_suffix,5,2),'-',substr(_table_suffix,7,2)) as date,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`,
    UNNEST(event_params) as evt
    WHERE _table_suffix between '20200701' and '20200707'
    AND event_name = 'user_engagement') total
ON splash.user_pseudo_id = total.user_pseudo_id
AND splash.date = total.date
GROUP BY 1
ORDER BY 1;

-- 没有user_engagement的用户行为归类
SELECT
    out.date,
    COUNT(distinct CASE when rend.user_pseudo_id is not null then out.user_pseudo_id else null end) as round_end_exist,
    COUNT(distinct CASE when rend.user_pseudo_id is null AND combo.user_pseudo_id is not null then out.user_pseudo_id else null end) as combo_exist,
    COUNT(distinct CASE when rend.user_pseudo_id is null AND combo.user_pseudo_id is null AND splash.user_pseudo_id is not null then out.user_pseudo_id else null end) as only_splash,
    COUNT(distinct CASE when rend.user_pseudo_id is null AND combo.user_pseudo_id is null AND splash.user_pseudo_id is null AND user_info.user_pseudo_id is not null then out.user_pseudo_id else null end) as only_user_info,
    COUNT(distinct CASE when rend.user_pseudo_id is null AND combo.user_pseudo_id is null AND splash.user_pseudo_id is null AND user_info.user_pseudo_id is null then out.user_pseudo_id else null end) as other_users
FROM
    (SELECT
        splash.date,
        splash.user_pseudo_id
    FROM 
        (SELECT
            distinct concat(substr(_table_suffix,0,4),'-',substr(_table_suffix,5,2),'-',substr(_table_suffix,7,2)) as date,
            user_pseudo_id
        FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`,
        UNNEST(event_params) as evt
        WHERE _table_suffix between '20200701' and '20200707'
        AND event_name not in ('os_update','act_set_notification','act_receive_notification','firebase_campaign','first_open','user_engagement')) splash
    LEFT JOIN
        (SELECT
            distinct concat(substr(_table_suffix,0,4),'-',substr(_table_suffix,5,2),'-',substr(_table_suffix,7,2)) as date,
            user_pseudo_id
        FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`,
        UNNEST(event_params) as evt
        WHERE _table_suffix between '20200701' and '20200707'
        AND event_name = 'user_engagement') total
    ON splash.user_pseudo_id = total.user_pseudo_id
    AND splash.date = total.date
    WHERE total.user_pseudo_id is null) out 
LEFT JOIN 
    (SELECT
        distinct concat(substr(_table_suffix,0,4),'-',substr(_table_suffix,5,2),'-',substr(_table_suffix,7,2)) as date,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`,
    UNNEST(event_params) as evt
    WHERE _table_suffix between '20200701' and '20200707'
    AND event_name = 'act_round_end') rend 
ON rend.user_pseudo_id = out.user_pseudo_id
AND rend.date = out.date 
LEFT JOIN 
    (SELECT
        distinct concat(substr(_table_suffix,0,4),'-',substr(_table_suffix,5,2),'-',substr(_table_suffix,7,2)) as date,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`,
    UNNEST(event_params) as evt
    WHERE _table_suffix between '20200701' and '20200707'
    AND event_name = 'act_combo') combo
ON combo.user_pseudo_id = out.user_pseudo_id
AND combo.date = out.date 
LEFT JOIN 
    (SELECT
        distinct concat(substr(_table_suffix,0,4),'-',substr(_table_suffix,5,2),'-',substr(_table_suffix,7,2)) as date,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`,
    UNNEST(event_params) as evt
    WHERE _table_suffix between '20200701' and '20200707'
    AND event_name = 'scr_splash') splash
ON splash.user_pseudo_id = out.user_pseudo_id
AND splash.date = out.date 
LEFT JOIN 
    (SELECT
        distinct concat(substr(_table_suffix,0,4),'-',substr(_table_suffix,5,2),'-',substr(_table_suffix,7,2)) as date,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`,
    UNNEST(event_params) as evt
    WHERE _table_suffix between '20200701' and '20200707'
    AND event_name = 'user_info') user_info
ON user_info.user_pseudo_id = out.user_pseudo_id
AND user_info.date = out.date 
GROUP BY 1
ORDER BY 1;

-- NU分media source
SELECT
    m.media_source,
    COUNT(distinct u.user_pseudo_id) as users
FROM
    (SELECT
        c.user_pseudo_id
    FROM
        (SELECT
            distinct user_pseudo_id
        FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`,
        UNNEST(event_params) as evt
        WHERE _table_suffix = '20200601'
        AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign')
        AND living_days = 0) c
    LEFT JOIN 
        (SELECT
            distinct user_pseudo_id
        FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`,
        UNNEST(event_params) as evt
        WHERE _table_suffix = '20200601'
        AND event_name = 'act_round_end'
        AND living_days = 0) rend  
    ON c.user_pseudo_id = rend.user_pseudo_id
    WHERE rend.user_pseudo_id is null) u 
LEFT JOIN
    (SELECT
        user_pseudo_id,
        MIN(media_source) as media_source
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
    WHERE _table_suffix = '20200601'
    GROUP BY 1) m 
ON u.user_pseudo_id = m.user_pseudo_id
GROUP BY 1

-- 计算每一天的rentention rate
SELECT
    r.date,
    COUNT(distinct r.user_pseudo_id)
FROM
    (SELECT
        distinct concat(substr(_table_suffix,0,4),'-',substr(_table_suffix,5,2),'-',substr(_table_suffix,7,2)) as date,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`,
    UNNEST(event_params) as evt
    WHERE _table_suffix = '20200607'
    AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')
    AND living_days = 0) c
LEFT JOIN
    (SELECT
        distinct concat(substr(_table_suffix,0,4),'-',substr(_table_suffix,5,2),'-',substr(_table_suffix,7,2)) as date,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`,
    UNNEST(event_params) as evt
    WHERE _table_suffix between '20200607' AND '20200629'
    AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')
    AND DATE_ADD(cast(concat(substr(_table_suffix,0,4),'-',substr(_table_suffix,5,2),'-',substr(_table_suffix,7,2)) as date), INTERVAL 0-living_days DAY) 
        = date '2020-06-07') r 
ON r.user_pseudo_id = c.user_pseudo_id
GROUP BY 1
ORDER BY 1;

-- 新用户数量和分类归因
SELECT
    c.date,
    COUNT(distinct c.user_pseudo_id) as custom_new_user,
    COUNT(distinct rend.user_pseudo_id) as rend_new_user,
    COUNT(distinct case when rend.user_pseudo_id is null then c.user_pseudo_id else null end) as custom_not_rend,
    COUNT(distinct case when rend.user_pseudo_id is null AND combo.user_pseudo_id is not null then c.user_pseudo_id else null end) as combo,
    COUNT(distinct case when rend.user_pseudo_id is null AND combo.user_pseudo_id is null 
        AND ngf.user_pseudo_id is not null then c.user_pseudo_id else null end) as new_guide_finish,
    COUNT(distinct case when rend.user_pseudo_id is null AND combo.user_pseudo_id is null 
        AND ngf.user_pseudo_id is null AND ngs.user_pseudo_id is not null then c.user_pseudo_id else null end) as new_guide_see,  
    COUNT(distinct case when rend.user_pseudo_id is null AND combo.user_pseudo_id is null 
        AND ngf.user_pseudo_id is null AND ngs.user_pseudo_id is null 
        AND fo.user_pseudo_id is not null then c.user_pseudo_id else null end) as first_open,  
    COUNT(distinct case when rend.user_pseudo_id is null AND combo.user_pseudo_id is null 
        AND ngf.user_pseudo_id is null AND ngs.user_pseudo_id is null 
        AND fo.user_pseudo_id is null then c.user_pseudo_id else null end) as other
FROM
    (SELECT
        distinct concat(substr(_table_suffix,0,4),'-',substr(_table_suffix,5,2),'-',substr(_table_suffix,7,2)) as date,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`,
    UNNEST(event_params) as evt
    WHERE _table_suffix between '20200601' AND '20200607'
    AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')
    AND living_days = 0) c
LEFT JOIN 
    (SELECT
        distinct concat(substr(_table_suffix,0,4),'-',substr(_table_suffix,5,2),'-',substr(_table_suffix,7,2)) as date,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`,
    UNNEST(event_params) as evt
    WHERE _table_suffix between '20200601' AND '20200607'
    AND event_name = 'act_round_end'
    AND living_days = 0) rend 
ON c.date = rend.date 
AND c.user_pseudo_id = rend.user_pseudo_id
LEFT JOIN 
    (SELECT
        distinct concat(substr(_table_suffix,0,4),'-',substr(_table_suffix,5,2),'-',substr(_table_suffix,7,2)) as date,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`,
    UNNEST(event_params) as evt
    WHERE _table_suffix between '20200601' AND '20200607'
    AND event_name = 'act_combo'
    AND living_days = 0) combo
ON c.date = combo.date 
AND c.user_pseudo_id = combo.user_pseudo_id
LEFT JOIN 
    (SELECT
        distinct concat(substr(_table_suffix,0,4),'-',substr(_table_suffix,5,2),'-',substr(_table_suffix,7,2)) as date,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`,
    UNNEST(event_params) as evt
    WHERE _table_suffix between '20200601' AND '20200607'
    AND event_name = 'src_new_guide'
    AND evt.key = 'finish'
    AND living_days = 0) ngf
ON c.date = ngf.date 
AND c.user_pseudo_id = ngf.user_pseudo_id
LEFT JOIN 
    (SELECT
        distinct concat(substr(_table_suffix,0,4),'-',substr(_table_suffix,5,2),'-',substr(_table_suffix,7,2)) as date,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`,
    UNNEST(event_params) as evt
    WHERE _table_suffix between '20200601' AND '20200607'
    AND event_name = 'src_new_guide'
    AND living_days = 0) ngs
ON c.date = ngs.date 
AND c.user_pseudo_id = ngs.user_pseudo_id
LEFT JOIN 
    (SELECT
        distinct concat(substr(_table_suffix,0,4),'-',substr(_table_suffix,5,2),'-',substr(_table_suffix,7,2)) as date,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`,
    UNNEST(event_params) as evt
    WHERE _table_suffix between '20200601' AND '20200607'
    AND event_name = 'first_open'
    AND living_days = 0) fo
ON c.date = fo.date 
AND c.user_pseudo_id = fo.user_pseudo_id
GROUP BY 1 
ORDER BY 1;

-- reinstall retention
SELECT
    r.date,
    COUNT(distinct r.user_id) as users
FROM
    (SELECT
        distinct Customer_User_ID
    FROM `blockpuzzle-f21e1.warehouse.xinyao_temp_reinstall`) u
LEFT JOIN 
    (SELECT
        distinct concat(substr(_table_suffix,0,4),'-',substr(_table_suffix,5,2),'-',substr(_table_suffix,7,2)) as date,
        user_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`,
    UNNEST(event_params) as evt
    WHERE _table_suffix between '20200602' AND '20200608'
    AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign')
    AND living_days = 1) r 
ON u.Customer_User_ID = r.user_id
GROUP BY 1
ORDER BY 1

-- 分国家验证次留绝对值差异
SELECT
    c.date,
    c.country,
    COUNT(distinct r.user_pseudo_id)
FROM
    (SELECT
        distinct concat(substr(_table_suffix,0,4),'-',substr(_table_suffix,5,2),'-',substr(_table_suffix,7,2)) as date,
        geo.country,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`,
    UNNEST(event_params) as evt
    WHERE _table_suffix between '20200601' and '20200607'
    AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')
    AND living_days = 0) c
LEFT JOIN
    (SELECT
        distinct concat(substr(_table_suffix,0,4),'-',substr(_table_suffix,5,2),'-',substr(_table_suffix,7,2)) as date,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`,
    UNNEST(event_params) as evt
    WHERE _table_suffix between '20200602' AND '20200608'
    AND event_name not in ('act_set_notification','act_receive_notification','os_update','firebase_campaign','first_open','user_engagement')
    AND living_days = 1) r 
ON r.user_pseudo_id = c.user_pseudo_id
GROUP BY 1,2
HAVING COUNT(distinct r.user_pseudo_id) > 1000
ORDER BY 1,3 DESC;