SELECT
    date,
    CASE when country in ('United States','United Kingdom','Germany','France','Spain','Russia','Japan','Mexico','Brazil') then country else 'Other' end as country,
    COUNT(distinct user_pseudo_id) as dau,
    COUNT(distinct CASE when living_days = 0 then user_pseudo_id else null end) as nu,
    COUNT(distinct CASE when living_days = 0 and media_source != 'Organic' then user_pseudo_id else null end) as ua_nu,
    COUNT(distinct CASE when living_days = 7 then user_pseudo_id else null end) as d7_retend,
    SUM(crush_rows) as crush_rows
FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
WHERE date between '2020-10-21' and '2020-10-27'
GROUP BY 1,2