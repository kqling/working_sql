SELECT
    u.create_date,
    'United States' as country, -- 这里需要改国家
    date_diff(r.date, u.create_date, day) as living_days,
    COUNT(distinct u.user_pseudo_id) as organic_user
FROM
    (SELECT
        distinct create_date,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.dim_dwd_action_userInfo_a`
    WHERE create_date between '2020-09-15' and '2020-09-27'
    AND first_day_geo.country = 'United States' -- 总共要9 个国家的以及全球的，算是10个国家
    -- 9个国家分别是：'United States','United Kingdom','Germany','France','Spain','Russia','Japan','Mexico','Brazil'
    AND media_source = 'Organic' -- 跑全部的时候只要把这个删掉就好
    ) u
LEFT JOIN
    (SELECT
        distinct date, user_pseudo_id
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
    WHERE date between '2020-09-15' and '2020-10-27') r
ON u.user_pseudo_id = r.user_pseudo_id
GROUP BY 1,2,3
ORDER BY 1,2,3;