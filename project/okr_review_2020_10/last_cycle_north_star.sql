SELECT
    date,
    CASE when country in ('United States','United Kingdom','Germany','France','Spain','Russia','Japan','Mexico','Brazil') then country else 'Other' end as country,
    SUM(crush_rows) as crush_rows
FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
WHERE date between '2020-10-14' and '2020-10-20'
GROUP BY 1,2
ORDER BY 1,2