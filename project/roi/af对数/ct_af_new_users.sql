create table if not exists `blockpuzzle-f21e1.warehouse.xinyao_temp_af_bigquery_retention_aligning`
as
SELECT 
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
FROM `foradmobapi.af_data_locker.blocked_installs_*`
WHERE _table_suffix between '20200918' and '20200920'
AND app_id = 'puzzle.blockpuzzle.cube.relax'
UNION ALL
SELECT 
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
FROM `foradmobapi.af_data_locker.installs_*`
WHERE _table_suffix between '20200918' and '20200920'
AND app_id = 'puzzle.blockpuzzle.cube.relax'
UNION ALL
SELECT 
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
FROM `foradmobapi.af_data_locker.organic_reinstalls_*`
WHERE _table_suffix between '20200918' and '20200920'
AND app_id = 'puzzle.blockpuzzle.cube.relax'
UNION ALL
SELECT 
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
FROM `foradmobapi.af_data_locker.reinstalls_*`
WHERE _table_suffix between '20200918' and '20200920'
AND app_id = 'puzzle.blockpuzzle.cube.relax'
UNION ALL
SELECT 
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
FROM `foradmobapi.af_data_locker.conversions_retargeting_*`
WHERE _table_suffix between '20200918' and '20200920'
AND app_id = 'puzzle.blockpuzzle.cube.relax';