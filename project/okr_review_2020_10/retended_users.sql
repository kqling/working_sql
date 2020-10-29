SELECT
    date,
    CASE when country in ('United States','United Kingdom','Germany','France','Spain','Russia','Japan','Mexico','Brazil') then country else 'Other' end as country,
    COUNT(distinct user_pseudo_id) as d7_nu
FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
WHERE date between '2020-10-14' and '2020-10-20'
AND living_days = 0
GROUP BY 1,2
ORDER BY 1,2;