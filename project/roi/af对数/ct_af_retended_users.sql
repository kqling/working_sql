create table if not exists `blockpuzzle-f21e1.warehouse.xinyao_temp_af_bigquery_af_retended_user`
as
SELECT
    install_time,
    event_name,
    event_time,
    media_source,
    country_code,
    appsflyer_id,
    customer_user_id,
    android_id,
    advertising_id,
    imei,
    idfa,
    idfv,
    platform
FROM `foradmobapi.af_data_locker.sessions_*`
WHERE _table_suffix between '20200918' and '20200920'
AND app_id = 'puzzle.blockpuzzle.cube.relax'
UNION ALL
SELECT
    install_time,
    event_name,
    event_time,
    media_source,
    country_code,
    appsflyer_id,
    customer_user_id,
    android_id,
    advertising_id,
    imei,
    idfa,
    idfv,
    platform
FROM `foradmobapi.af_data_locker.sessions_retargeting_*`
WHERE _table_suffix between '20200918' and '20200920'
AND app_id = 'puzzle.blockpuzzle.cube.relax';