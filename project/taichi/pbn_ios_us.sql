SELECT
    date,
    user_pseudo_id,
    app_version,
    revenue,
    rank_perc
FROM
    (SELECT
        date,
        user_pseudo_id,
        app_version,
        revenue,
        percent_rank() OVER(ORDER BY revenue DESC) as rank_perc
    FROM
        (SELECT
            s.date,
            s.user_pseudo_id,
            app_version,
            round(sum(ifnull(s.total_show, 0) * ifnull(e.ecpm, 0) / 1000), 2) as revenue
        FROM
            (select 
                summary_date,
                user_pseudo_id,
                app_version,
                ad_id,
                country,
                date_add(current_date(), interval -30 day) as date,
                SUM(true_show) as total_show
            from `paint-by-number-3c789.bi_data_warehouse.adsdk_events_ios_*`
            where parse_date('%Y%m%d',_table_suffix) between date_add(current_date(), interval -30 day) and date_add(current_date(), interval -10 day)
            AND country = 'United States'
            AND DATE_ADD(parse_date('%Y%m%d',_table_suffix),interval 0-living_days DAY) = date_add(current_date(), interval -30 day)
            and parse_date('%Y%m%d',summary_date) between date_add(current_date(), interval -30 day) and date_add(current_date(), interval -23 day)
            GROUP BY 1,2,3,4,5,6
            HAVING total_show > 0) s
        left join `paint-by-number-3c789.bi_data_warehouse.unit_ecpm_ios` e   
        ON s.summary_date = e.date
        AND s.ad_id = e.unit_id
        and s.country = e.country
        GROUP BY 1,2,3))
WHERE rank_perc <= 0.3