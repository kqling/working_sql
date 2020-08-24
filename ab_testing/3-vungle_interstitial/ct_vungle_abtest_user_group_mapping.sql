create table if not exists `blockpuzzle-f21e1.warehouse.xinyao_temp_vungle_abtest_user_group_mapping`
as
select
    case when config = 'US_default_0806' then 'control' else 'test' end as ab_group,
    user_pseudo_id,
    MIN(summary_date) as first_date
from
    (SELECT 
        parse_date('%Y%m%d',_table_suffix) as summary_date,
        FIRST_VALUE(ep.value) OVER (PARTITION BY user_pseudo_id ORDER BY event_timestamp DESC) AS config,
        user_pseudo_id
    FROM `blockpuzzle-f21e1.bi_data_warehouse.adsdk_basic_events_android_*`,
    UNNEST (event_params) AS ep
    WHERE _table_suffix BETWEEN '20200806' AND '20200818'
    AND event_name = 'adsdk_init'
    AND ep.key = 'configName'
    AND ep.value IN ('US_test_0806','US_default_0806')
    AND geo.country = 'United States')
GROUP BY 1,2

