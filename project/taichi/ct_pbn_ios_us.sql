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
            s.date,
            s.user_pseudo_id,
            app_version,
            round(sum(ifnull(s.two_day_total_show, 0) * ifnull(e.ecpm, 0) / 1000), 2) as two_day_revenue,
            round(sum(ifnull(s.four_day_total_show, 0) * ifnull(e.ecpm, 0) / 1000), 2) as four_day_revenue,
            round(sum(ifnull(s.six_day_total_show, 0) * ifnull(e.ecpm, 0) / 1000), 2) as six_day_revenue
        FROM
            (select 
                summary_date,
                user_pseudo_id,
                app_version,
                ad_id,
                country,
                date_add(@run_date, interval -7 day) as date,
                SUM(case when parse_date('%Y%m%d',summary_date) between date_add(@run_date, interval -7 day)
                            and date_add(@run_date, interval -6 day)
                        then true_show else 0 end) as two_day_total_show,
                SUM(case when parse_date('%Y%m%d',summary_date) between date_add(@run_date, interval -7 day)
                            and date_add(@run_date, interval -4 day)
                        then true_show else 0 end) as four_day_total_show,
                SUM(true_show) as six_day_total_show
            from `paint-by-number-3c789.bi_data_warehouse.adsdk_events_ios_*`
            where parse_date('%Y%m%d',_table_suffix) between date_add(@run_date, interval -7 day) and @run_date
            --create_date是7天前
            AND DATE_ADD(parse_date('%Y%m%d',_table_suffix),interval 0-living_days DAY) = date_add(@run_date, interval -7 day) 
            --广告实际发生的时间是6天内
            and parse_date('%Y%m%d',summary_date) between date_add(@run_date, interval -7 day) and date_add(@run_date, interval -2 day)
            and country = 'United States'
            GROUP BY 1,2,3,4,5,6
            HAVING two_day_total_show > 0 and two_day_total_show < 1000000) s
        left join 
            (select 
                iaa_platform, 
                date, 
                unit_id, 
                ip_name as country_name, 
                s1.country_code,
                ifnull(sum(revenue), 0) as revenue, ifnull(sum(impression), 0) as impression,
                round(ifnull(safe_divide(sum(revenue), sum(impression)) * 1000, 0), 10) as ecpm
            from `foradmobapi.learnings_data_warehouse.fact_dwd_iaa_unitRevenue_di_*` s1 
            join 
                (select 
                    k2.app_id, 
                    k2.platform 
                from `foradmobapi.learnings_data_warehouse.dim_dwd_iaa_application_a` k2
                where production_id = '5b892d3a9f9b4e00011d1cf3'
                ) s2 
            on s1.app_id = s2.app_id 
            and ifnull(s1.platform, 'nt') = ifnull(s2.platform, 'nt')
            left join `foradmobapi.learnings_data_warehouse.dim_dwd_basic_country_a` s3 
            on s1.country_code = s3.country_code
            where parse_date('%Y%m%d',_TABLE_SUFFIX) between date_add(@run_date, interval -7 day) and date_add(@run_date, interval -2 day)
            group by 1, 2, 3, 4, 5) e   
        ON parse_date('%Y%m%d',s.summary_date) = e.date
        AND s.ad_id = e.unit_id
        and s.country = e.country_name
        GROUP BY 1,2,3))
WHERE (two_day_rank_perc <= 0.3 or four_day_rank_perc <= 0.3 or six_day_rank_perc <= 0.3)