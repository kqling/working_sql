SELECT
    u.create_date,
    u.country,
    COUNT(distinct u.user_pseudo_id) as organic_user,
    COUNT(distinct r.user_pseudo_id) as d7_organic_retended
FROM
    (SELECT
        distinct create_date,
        CASE when first_day_geo.country in ('United States','United Kingdom','Germany','France','Spain','Russia','Japan','Mexico','Brazil') then first_day_geo.country
        else 'Other' end as country,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.dim_dwd_action_userInfo_a`
    WHERE create_date between '2020-10-14' and '2020-10-20'
    AND media_source = 'Organic') u
LEFT JOIN
    (SELECT
        distinct user_pseudo_id
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
    WHERE date between '2020-10-21' and '2020-10-27'
    AND living_days = 7) r
ON u.user_pseudo_id = r.user_pseudo_id
GROUP BY 1,2
ORDER BY 1,2