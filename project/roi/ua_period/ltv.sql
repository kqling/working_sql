SELECT
    living_days,
    media_source,
    first_day_country,
    COUNT(distinct user_pseudo_id) as users,
    SUM(accumulated_revenue) as accumulated_revenue
FROM
    (SELECT
        user_pseudo_id,
        media_source,
        first_day_country,
        living_days,
        SUM(ad_revenue) over(partition by user_pseudo_id ORDER BY living_days range between unbounded preceding and current row) as accumulated_revenue
    FROM `blockpuzzle-f21e1.warehouse.xinyao_temp_roi_everyday_revenue`)
GROUP BY 1,2,3
ORDER BY 1,2,3