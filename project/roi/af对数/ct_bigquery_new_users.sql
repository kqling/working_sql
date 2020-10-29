create table if not exists `blockpuzzle-f21e1.warehouse.xinyao_temp_af_bigquery_bigquery_new_user`
as
SELECT
    distinct u.create_date,
    u.user_pseudo_id,
    uuid.uuid,
    uuid.advertising_id,
    u.country,
    u.media_source,
    u.app_version -- 只有1.9.0以上版本才会发uuid
FROM
    (SELECT 
        create_date, 
        user_pseudo_id, 
        media_source, 
        first_day_geo.country as country,
        first_day_app_info.version as app_version
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.dim_dwd_action_userInfo_a`
    WHERE create_date between '2020-09-18' and '2020-09-20') u 
LEFT JOIN
    (SELECT 
        distinct parse_date('%Y%m%d',_table_suffix) as create_date,
        user_pseudo_id,
        up.value.string_value as uuid,
        device.advertising_id as advertising_id
    FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.fact_ods_action_basicEvents_di_*`,
    UNNEST(user_properties) as up
    WHERE _table_suffix between '20200918' and '20200920'
    AND up.key = 'client_uuid') uuid
ON uuid.user_pseudo_id = u.user_pseudo_id