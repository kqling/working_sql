SELECT
    date,
    create_date,
    user_pseudo_id,
    app_version,
    ad_revenue,
    rank_perc
FROM
    (SELECT
        date,
        create_date,
        user_pseudo_id,
        app_version,
        ad_revenue,
        percent_rank() OVER(partition by create_date ORDER BY ad_revenue DESC) as rank_perc
    FROM
        (SELECT
            s.date,
            s.create_date,
            s.user_pseudo_id,
            app_version,
            round(sum(ifnull(s.total_show, 0) * ifnull(e.ecpm, 0) / 1000), 2) as ad_revenue
        FROM
            (select 
                summary_date,
                DATE_ADD(parse_date('%Y%m%d',_table_suffix),interval 0-living_days DAY) as create_date,
                user_pseudo_id,
                app_version,
                ad_id,
                country,
                DATE_SUB(@run_date, INTERVAL 0 DAY) AS date,
                SUM(true_show) as total_show
            from `paint-by-number-3c789.bi_data_warehouse.adsdk_events_ios_*`
            where parse_date('%Y%m%d',_table_suffix) between date_add(@run_date, interval -8 day) and date_add(@run_date, interval -2 day)
            --create_date是7天前
            AND DATE_ADD(parse_date('%Y%m%d',_table_suffix),interval 0-living_days DAY) between date_add(@run_date, interval -8 day) and date_add(@run_date, interval -2 day) 
            --广告实际发生的时间是6天内
            and parse_date('%Y%m%d',summary_date) between date_add(@run_date, interval -8 day) and date_add(@run_date, interval -2 day)
            and country = 'United States'
            GROUP BY 1,2,3,4,5,6,7
            HAVING total_show > 0 and total_show < 1000000) s
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
            where parse_date('%Y%m%d',_TABLE_SUFFIX) between date_add(@run_date, interval -8 day) and date_add(@run_date, interval -2 day)
            group by 1, 2, 3, 4, 5) e   
        ON parse_date('%Y%m%d',s.summary_date) = e.date
        AND s.ad_id = e.unit_id
        and s.country = e.country_name
        GROUP BY 1,2,3,4))
WHERE rank_perc <= 0.3