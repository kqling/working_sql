select
    ab_group,
    day_num,
    first_date,
    count(distinct user_pseudo_id) as users
from
    (select
        u.ab_group,
        u.user_pseudo_id,
        u.first_date,
        date_diff(parse_date('%Y%m%d',r._table_suffix),u.first_date,day) as day_num
    from
        (select
            u.ab_group,
            u.user_pseudo_id,
            min(parse_date('%Y%m%d',_table_suffix)) as first_date
        from `blockpuzzle-f21e1.warehouse.xinyao_temp_vungle_abtest_user_group_mapping` u 
        INNER JOIN `blockpuzzle-f21e1.bi_data_warehouse.active_users_android_*` r
        ON r._table_suffix between '20200806' and '20200818'
        and r.user_pseudo_id = u.user_pseudo_id
        and parse_date('%Y%m%d',r._table_suffix) >= u.first_date
        where r.living_days = 0
        group by 1,2) u 
    LEFT JOIN `blockpuzzle-f21e1.bi_data_warehouse.active_users_android_*` r
    ON r._table_suffix between '20200806' and '20200818'
    and r.user_pseudo_id = u.user_pseudo_id)
group by 1,2,3
order by 3,2,1



