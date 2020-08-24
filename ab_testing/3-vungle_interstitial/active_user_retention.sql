select
    u.date,
    u.ab_group,
    count(distinct u.user_pseudo_id) as user,
    count(distinct r.user_pseudo_id) as retended_users,
    cast(count(distinct r.user_pseudo_id) as float64)/count(distinct u.user_pseudo_id) as D1_retention_rate
from
    (select
        u.ab_group,
        u.user_pseudo_id,
        parse_date('%Y%m%d',r._table_suffix) as date
    from `blockpuzzle-f21e1.warehouse.xinyao_temp_vungle_abtest_user_group_mapping` u 
    LEFT JOIN `blockpuzzle-f21e1.bi_data_warehouse.active_users_android_*` r
    ON r._table_suffix between '20200806' and '20200818'
    and r.user_pseudo_id = u.user_pseudo_id
    and parse_date('%Y%m%d',r._table_suffix) >= u.first_date) u 
left join
    (select
        u.ab_group,
        u.user_pseudo_id,
        parse_date('%Y%m%d',r._table_suffix) as date
    from `blockpuzzle-f21e1.warehouse.xinyao_temp_vungle_abtest_user_group_mapping` u 
    LEFT JOIN `blockpuzzle-f21e1.bi_data_warehouse.active_users_android_*` r
    ON r._table_suffix between '20200806' and '20200818'
    and r.user_pseudo_id = u.user_pseudo_id
    and parse_date('%Y%m%d',r._table_suffix) >= u.first_date) r 
on u.user_pseudo_id = r.user_pseudo_id
and date_add(u.date, interval 7 day) = r.date
group by 1,2
order by 1,2