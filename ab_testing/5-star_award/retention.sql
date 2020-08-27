select
    date,
    ab_group,
    SUM(users) as users,
    SUM(retended_users) as retended_users,
    cast(SUM(retended_users) as float64)/SUM(users) as retention_rate
from
    (select
        u.date,
        u.ab_group,
        COUNT(distinct u.user_pseudo_id) as users,
        COUNT(distinct r.user_pseudo_id) as retended_users
    from
        (select
            distinct parse_date('%Y%m%d',_table_suffix) as date,
            user_pseudo_id,
            case when abtest_tag like '%Ix1%' then 'control' else 'test' end as ab_group
        from `blockpuzzle-f21e1.bi_data_warehouse.active_users_android_*`
        where _table_suffix between '20200816' and '20200824'
        and (abtest_tag like '%Ix1%' or (abtest_tag like '%Ix0%' and abtest_tag not like '%Oa1%'))
        and app_version >= '001009003000000') u 
    LEFT JOIN 
        (select
            distinct parse_date('%Y%m%d',_table_suffix) as date,
            user_pseudo_id
        from `blockpuzzle-f21e1.bi_data_warehouse.active_users_android_*`
        where _table_suffix between '20200816' and '20200824'
        and (abtest_tag like '%Ix1%' or (abtest_tag like '%Ix0%' and abtest_tag not like '%Oa1%'))
        and app_version >= '001009003000000') r
    ON u.user_pseudo_id = r.user_pseudo_id
    AND DATE_ADD(u.date, INTERVAL 1 day) = r.date
    GROUP BY 1,2
    union all
    select
        u.date,
        u.ab_group,
        COUNT(distinct u.user_pseudo_id) as users,
        COUNT(distinct r.user_pseudo_id) as retended_users
    from
        (select
            distinct parse_date('%Y%m%d',_table_suffix) as date,
            user_pseudo_id,
            case when abtest_tag like '%Yv1%' then 'control' else 'test' end as ab_group
        from `blockpuzzle-f21e1.bi_data_warehouse.active_users_ios_*`
        where _table_suffix between '20200816' and '20200824'
        and (abtest_tag like '%Yv1%' or (abtest_tag like '%Yv0%' and abtest_tag not like '%Ua1%'))
        and app_version >= '001009003000000') u 
    LEFT JOIN 
        (select
            distinct parse_date('%Y%m%d',_table_suffix) as date,
            user_pseudo_id
        from `blockpuzzle-f21e1.bi_data_warehouse.active_users_ios_*`
        where _table_suffix between '20200816' and '20200824'
        and (abtest_tag like '%Yv1%' or (abtest_tag like '%Yv0%' and abtest_tag not like '%Ua1%'))
        and app_version >= '001009003000000') r
    ON u.user_pseudo_id = r.user_pseudo_id
    AND DATE_ADD(u.date, INTERVAL 1 day) = r.date
    GROUP BY 1,2)
GROUP BY 1,2
ORDER BY 1,2
