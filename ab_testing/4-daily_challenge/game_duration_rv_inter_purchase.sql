SELECT
    date,
    ab_group,
    SUM(users) as users,
    SUM(rv_show) as rv_show,
    SUM(inter_show) as inter_show,
    SUM(prop_purchase) as prop_purchase,
    SUM(game_num) as game_num,
    SUM(duration_min) as duration_min
FROM
    (SELECT
        'Android' as platform,
        u.date,
        u.ab_group,
        count(distinct u.user_pseudo_id) as users,
        SUM(rv_show) as rv_show,
        SUM(inter_show) as inter_show,
        SUM(prop_purchase) as prop_purchase,
        SUM(game_num) as game_num,
        SUM(duration_min) as duration_min
    FROM
        (select
            parse_date('%Y%m%d',_table_suffix) as date,
            user_pseudo_id,
            case when abtest_tag like '%Oa0%' then 'control' else 'test' end as ab_group,
            cast(SUM(duration) as float64)/60000 as duration_min
        from `blockpuzzle-f21e1.bi_data_warehouse.active_users_android_*`
        where _table_suffix between '20200816' and '20200824'
        and abtest_tag like '%Ix0%'
        and (abtest_tag like '%Oa0%' or abtest_tag like '%Oa1%')
        and app_version >= '001009003000000'
        group by 1,2,3) u 
    LEFT JOIN
        (select
            parse_date('%Y%m%d',_table_suffix) as date,
            user_pseudo_id,
            count(case when event_name = 'act_buy_item_success' then 1 else null end) as prop_purchase,
            count(case when event_name = 'act_adtry_rv_unite' then 1 else null end) as rv_show,
            count(case when event_name = 'act_adtry_interstitial_unite' then 1 else null end) as inter_show
        from `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`
        where _table_suffix between '20200816' and '20200824'
        and abtest_tag like '%Ix0%'
        and (abtest_tag like '%Oa0%' or abtest_tag like '%Oa1%')
        and app_version >= '001009003000000'
        and event_name in ('act_buy_item_success','act_adtry_rv_unite','act_adtry_interstitial_unite')
        group by 1,2) income
    ON u.user_pseudo_id = income.user_pseudo_id
    and u.date = income.date
    LEFT JOIN
        (select
            parse_date('%Y%m%d',_table_suffix) as date,
            user_pseudo_id,
            count(distinct evt.value) as game_num
        from `blockpuzzle-f21e1.bi_data_warehouse.basic_events_android_*`,
        unnest(event_params) as evt
        where _table_suffix between '20200816' and '20200824'
        and abtest_tag like '%Ix0%'
        and (abtest_tag like '%Oa0%' or abtest_tag like '%Oa1%')
        and app_version >= '001009003000000'
        and event_name = 'act_combo'
        and evt.key = 'play_count'
        group by 1,2) e
    ON u.user_pseudo_id = e.user_pseudo_id
    and u.date = e.date
    GROUP BY 1,2,3
    UNION ALL
    SELECT
        'iOS' as platform,
        u.date,
        u.ab_group,
        count(distinct u.user_pseudo_id) as users,
        SUM(rv_show) as rv_show,
        SUM(inter_show) as inter_show,
        SUM(prop_purchase) as prop_purchase,
        SUM(game_num) as game_num,
        SUM(duration_min) as duration_min
    FROM
        (select
            parse_date('%Y%m%d',_table_suffix) as date,
            user_pseudo_id,
            case when abtest_tag like '%Ua0%' then 'control' else 'test' end as ab_group,
            cast(SUM(duration) as float64)/60000 as duration_min
        from `blockpuzzle-f21e1.bi_data_warehouse.active_users_ios_*`
        where _table_suffix between '20200816' and '20200824'
        and abtest_tag like '%Yv0%'
        and (abtest_tag like '%Ua0%' or abtest_tag like '%Ua1%')
        and app_version >= '001009003000000'
        group by 1,2,3) u 
    LEFT JOIN
        (select
            parse_date('%Y%m%d',_table_suffix) as date,
            user_pseudo_id,
            count(case when event_name = 'act_buy_item_success' then 1 else null end) as prop_purchase,
            count(case when event_name = 'act_adtry_rv_unite' then 1 else null end) as rv_show,
            count(case when event_name = 'act_adtry_interstitial_unite' then 1 else null end) as inter_show
        from `blockpuzzle-f21e1.bi_data_warehouse.basic_events_ios_*`
        where _table_suffix between '20200816' and '20200824'
        and abtest_tag like '%Yv0%'
        and (abtest_tag like '%Ua0%' or abtest_tag like '%Ua1%')
        and app_version >= '001009003000000'
        and event_name in ('act_buy_item_success','act_adtry_rv_unite','act_adtry_interstitial_unite')
        group by 1,2) income
    ON u.user_pseudo_id = income.user_pseudo_id
    and u.date = income.date
    LEFT JOIN
        (select
            parse_date('%Y%m%d',_table_suffix) as date,
            user_pseudo_id,
            count(distinct evt.value) as game_num
        from `blockpuzzle-f21e1.bi_data_warehouse.basic_events_ios_*`,
        unnest(event_params) as evt
        where _table_suffix between '20200816' and '20200824'
        and abtest_tag like '%Yv0%'
        and (abtest_tag like '%Ua0%' or abtest_tag like '%Ua1%')
        and app_version >= '001009003000000'
        and event_name = 'act_combo'
        and evt.key = 'play_count'
        group by 1,2) e
    ON u.user_pseudo_id = e.user_pseudo_id
    and u.date = e.date
    GROUP BY 1,2,3)
GROUP BY 1,2
ORDER BY 1,2