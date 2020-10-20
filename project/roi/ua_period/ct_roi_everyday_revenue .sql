SELECT
    'Android' as platform,
    DATE_SUB(@run_date, INTERVAL 0 DAY) AS run_date,
    u.user_pseudo_id,
    u.media_source,
    u.first_day_country,
    date_diff(@run_date,u.create_date,day) as living_days,
    u.create_date,
    case when a.ad_revenue is not null then a.ad_revenue else 0 end as ad_revenue
FROM
    (SELECT
        distinct a.user_pseudo_id,
        u.first_day_geo.country as first_day_country,
        u.media_source,
        a.create_date
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*` a
    INNER JOIN `blockpuzzle-f21e1.learnings_data_warehouse_android.dim_dwd_action_userInfo_a` u 
    ON a.user_pseudo_id = u.user_pseudo_id
    AND u.first_day_geo.country in ('United States','United Kingdom','Germany','France','Spain','Russia','Japan','Mexico','Brazil')
    WHERE a.date between '2020-04-01' and '2020-08-31'
    AND a.create_date between date('2020-04-01') and @run_date) u
LEFT JOIN
    (SELECT
        a.date,
        a.user_pseudo_id,
        a.living_days,
        a.create_date,
        SUM(ad_revenue) as ad_revenue
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*` a
    INNER JOIN `blockpuzzle-f21e1.learnings_data_warehouse_android.dim_dwd_action_userInfo_a` u 
    ON a.user_pseudo_id = u.user_pseudo_id
    AND u.first_day_geo.country in ('United States','United Kingdom','Germany','France','Spain','Russia','Japan','Mexico','Brazil')
    WHERE a.date between '2020-04-01' and '2020-08-31'
    AND a.create_date between '2020-04-01' and '2020-08-31'
    GROUP BY 1,2,3,4) a
ON a.user_pseudo_id = u.user_pseudo_id
AND a.date = @run_date


