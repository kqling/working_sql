create table if not exists `blockpuzzle-f21e1.warehouse.xinyao_temp_vungle_abtest_user_group_mapping`
as
select
    min(parse_date('%Y%m%d',summary_date)) as first_date,
    case when config_name = 'US_default_0806' then 'control' else 'test' end as ab_group,
    user_pseudo_id
from `bi_data_warehouse.adsdk_events_android_*` 
where _table_suffix between '20200806' and '20200818'
and summary_date between '20200806' and '20200818'
and ad_app_version >= '001007009000000'
and country = 'United States'
and ad_type = 'interstitial'
and config_name in ('US_test_0806','US_default_0806')
group by 2,3