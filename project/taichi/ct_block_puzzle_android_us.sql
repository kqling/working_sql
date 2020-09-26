SELECT
    date,
    user_pseudo_id,
    app_version,
    two_day_revenue,
    four_day_revenue,
    six_day_revenue,
    two_day_rank_perc,
    four_day_rank_perc,
    six_day_rank_perc
FROM
    (SELECT
        date,
        user_pseudo_id,
        app_version,
        two_day_revenue,
        four_day_revenue,
        six_day_revenue,
        percent_rank() OVER(partition by date ORDER BY two_day_revenue DESC) as two_day_rank_perc,
        percent_rank() OVER(partition by date ORDER BY four_day_revenue DESC) as four_day_rank_perc,
        percent_rank() OVER(partition by date ORDER BY six_day_revenue DESC) as six_day_rank_perc
    FROM
        (SELECT
            u.date,
            u.user_pseudo_id,
            u.app_version,
            ad.two_day_revenue,
            ad.four_day_revenue,
            ad.six_day_revenue
        FROM
            (SELECT
                create_date as date,
                user_pseudo_id,
                app_version
            FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.dim_dwd_action_userInfo_a`
            WHERE first_day_geo.country = 'United States'
            AND create_date = DATE_ADD(@run_date, interval -8 day)
            ) u
        LEFT JOIN
            (SELECT
                user_pseudo_id,
                SUM(CASE when date between date_add(@run_date, interval -8 day) and date_add(@run_date, interval -7 day) then ad_revenue else 0 end) as two_day_revenue,
                SUM(CASE when date between date_add(@run_date, interval -8 day) and date_add(@run_date, interval -5 day) then ad_revenue else 0 end) as four_day_revenue,
                SUM(ad_revenue) as six_day_revenue
            FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`
            WHERE date between DATE_ADD(@run_date, interval -8 day) and @run_date
            AND create_date = DATE_ADD(@run_date, interval -8 day)
            GROUP BY 1
            ) ad
        ON u.user_pseudo_id = ad.user_pseudo_id
        )
    )
WHERE (two_day_rank_perc <= 0.3 or four_day_rank_perc <= 0.3 or six_day_rank_perc <= 0.3)