CREATE TABLE `paint-by-number-3c789.warehouse.temp_taichi_last7day_5country_dau_fake_revenue`
as
SELECT
    s.date,
    s.user_pseudo_id,
    s.country,
    round(sum(ifnull(s.total_show, 0) * ifnull(e.ecpm, 0) / 1000), 2)*7 as revenue
FROM
    (select 
        parse_date('%Y%m%d',summary_date) as date,
        user_pseudo_id,
        ad_id,
        country,
        SUM(true_show) as total_show
    from `paint-by-number-3c789.bi_data_warehouse.adsdk_events_android_*`
    where parse_date('%Y%m%d',_table_suffix) between date_add(CURRENT_DATE(), interval -7 day) and CURRENT_DATE()
    and parse_date('%Y%m%d',summary_date) between date_add(CURRENT_DATE(), interval -7 day) and CURRENT_DATE()
    and country in ('United States','Russia','Brazil','Mexico','India')
    GROUP BY 1,2,3,4
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
        where production_id = '5b84f58e689998000116d3fd'
        ) s2 
    on s1.app_id = s2.app_id 
    and ifnull(s1.platform, 'nt') = ifnull(s2.platform, 'nt')
    left join `foradmobapi.learnings_data_warehouse.dim_dwd_basic_country_a` s3 
    on s1.country_code = s3.country_code
    where parse_date('%Y%m%d',_TABLE_SUFFIX) between date_add(CURRENT_DATE(), interval -7 day) and CURRENT_DATE()
    group by 1, 2, 3, 4, 5) e   
ON s.date = e.date
AND s.ad_id = e.unit_id
and s.country = e.country_name
GROUP BY 1,2,3