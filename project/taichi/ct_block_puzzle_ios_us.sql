SELECT
    @run_date as date,
    create_date,
    user_pseudo_id,
    app_version,
    ad_revenue,
    rank_perc
FROM
    (SELECT
        create_date,
        user_pseudo_id,
        app_version,
        ad_revenue,
        percent_rank() OVER(partition by create_date ORDER BY ad_revenue DESC) as rank_perc
    FROM
        (SELECT
            u.create_date,
            u.user_pseudo_id,
            u.app_version,
            ad.ad_revenue
        FROM
            (SELECT
                create_date,
                user_pseudo_id,
                app_version
            FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.dim_dwd_action_userInfo_a`
            WHERE first_day_geo.country = 'United States'
            AND create_date between DATE_ADD(@run_date, interval -8 day) and DATE_ADD(@run_date, interval -2 day)
            ) u
        LEFT JOIN
            (SELECT
                user_pseudo_id,
                SUM(ad_revenue) as ad_revenue
            FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*`
            WHERE date between DATE_ADD(@run_date, interval -8 day) and DATE_ADD(@run_date, interval -2 day)
            AND create_date between DATE_ADD(@run_date, interval -8 day) and DATE_ADD(@run_date, interval -2 day)
            GROUP BY 1
            ) ad
        ON u.user_pseudo_id = ad.user_pseudo_id
        )
    )
WHERE rank_perc <= 0.3