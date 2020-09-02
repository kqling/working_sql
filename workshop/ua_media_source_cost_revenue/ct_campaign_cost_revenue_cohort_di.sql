SELECT
    platform,
    create_date,
    date,
    media_source,
    campaign_name,
    first_day_country,
    COUNT(distinct user_pseudo_id) as users,
    SUM(ua_cost) as ua_cost,
    SUM(ad_revenue) as ad_revenue
FROM
    (SELECT
        'iOS' as platform,
        di.create_date,
        di.date,
        di.media_source,
        di.campaign_name,
        u.first_day_geo.country as first_day_country,
        di.user_pseudo_id,
        ua_cost,
        SUM(ad_revenue) as ad_revenue
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*` di
    LEFT JOIN `blockpuzzle-f21e1.learnings_data_warehouse_ios.dim_dwd_action_userInfo_a` u 
    ON di.user_pseudo_id = u.user_pseudo_id
    WHERE di.date = @run_date
    AND di.campaign_name is not null
    GROUP BY 1,2,3,4,5,6,7,8)
GROUP BY 1,2,3,4,5,6
UNION ALL
SELECT
    platform,
    create_date,
    date,
    media_source,
    campaign_name,
    first_day_country,
    COUNT(distinct user_pseudo_id) as users,
    SUM(ua_cost) as ua_cost,
    SUM(ad_revenue) as ad_revenue
FROM
    (SELECT
        'Android' as platform,
        di.create_date,
        di.date,
        di.media_source,
        di.campaign_name,
        u.first_day_geo.country as first_day_country,
        di.user_pseudo_id,
        ua_cost,
        SUM(ad_revenue) as ad_revenue
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*` di
    LEFT JOIN `blockpuzzle-f21e1.learnings_data_warehouse_android.dim_dwd_action_userInfo_a` u 
    ON di.user_pseudo_id = u.user_pseudo_id
    WHERE di.date = @run_date
    AND di.campaign_name is not null
    GROUP BY 1,2,3,4,5,6,7,8)
GROUP BY 1,2,3,4,5,6