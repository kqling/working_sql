select
    active.date,
    active.ab_group,
    count(active.user_pseudo_id) as users,
    sum(ad.total_show) as true_show,
    sum(revenue) as revenue
from
    (select
        distinct parse_date('%Y%m%d',r._table_suffix) as date,
        u.ab_group,
        u.user_pseudo_id
    from `blockpuzzle-f21e1.warehouse.xinyao_temp_vungle_abtest_user_group_mapping` u 
    INNER JOIN `blockpuzzle-f21e1.bi_data_warehouse.active_users_android_*` r
    ON r._table_suffix between '20200806' and '20200818'
    and r.user_pseudo_id = u.user_pseudo_id) active
LEFT JOIN
    (select
        s.date,
        s.user_pseudo_id,
        sum(s.total_show) as total_show,
        round(sum(ifnull(s.total_show, 0) * ifnull(e.ecpm, 0) / 1000), 2) as revenue
    from
        (select
            parse_date('%Y%m%d',summary_date) as date,
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
        group by 1,2,3,4
        having total_show between 0 and 1000000) s
    LEFT JOIN `blockpuzzle-f21e1.learnings_data_warehouse_android.fact_dws_iaa_unitEcpm_a` e   
    ON s.date = e.date
    AND s.ad_id = e.unit_id
    and s.country = e.country_name
    group by 1,2
    ) ad
ON ad.date = active.date
and ad.user_pseudo_id = active.user_pseudo_id
group by 1,2
order by 1,2
