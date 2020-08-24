select
    date,
    ab_group,
    count(distinct user_pseudo_id) as users,
    sum(total_show) as total_show,
    sum(revenue) as revenue
from
    (select
        s.date,
        s.user_pseudo_id,
        s.ab_group,
        sum(s.total_show) as total_show,
        round(sum(ifnull(s.total_show, 0) * ifnull(e.ecpm, 0) / 1000), 2) as revenue
    from
        (select
            parse_date('%Y%m%d',summary_date) as date,
            case when config_name = 'US_default_0806' then 'control' else 'test' end as ab_group,
            user_pseudo_id,
            ad_id,
            country,
            sum(true_show) as total_show
        from `bi_data_warehouse.adsdk_events_android_*` 
        where _table_suffix between '20200806' and '20200818'
        and summary_date between '20200806' and '20200818'
        and app_version >= '001007009000000'
        and country = 'United States'
        and ad_type = 'interstitial'
        and config_name in ('US_test_0806','US_default_0806')
        group by 1,2,3,4,5
        having total_show between 0 and 1000000) s
    LEFT JOIN `blockpuzzle-f21e1.learnings_data_warehouse_android.fact_dws_iaa_unitEcpm_a` e   
    ON s.date = e.date
    AND s.ad_id = e.unit_id
    and s.country = e.country_name
    group by 1,2,3)
group by 1,2
order by 1,2