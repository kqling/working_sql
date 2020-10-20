SELECT
    af.af_create_date,
    af.customer_user_id,
    COUNT(distinct user_pseudo_id) as users
FROM
    (SELECT
        distinct date(cast(af.event_time as timestamp)) as af_create_date,
        af.customer_user_id
    FROM `blockpuzzle-f21e1.warehouse.xinyao_temp_af_bigquery_bigquery_new_user` b
    FULL OUTER JOIN `blockpuzzle-f21e1.warehouse.xinyao_temp_af_bigquery_retention_aligning` af 
    ON b.uuid = af.customer_user_id
    where b.uuid is null and af.customer_user_id is not null) af
LEFT JOIN
    (SELECT
        distinct luid, uuid, date(timestamp_seconds(cTime)) as create_date
    FROM `foradmobapi.learnings_data_warehouse.dim_ods_lu_androidLuid_a`,
    UNNEST(uuid) as uuid) uuid
ON af.customer_user_id = uuid.uuid
LEFT JOIN `blockpuzzle-f21e1.learnings_data_warehouse_android.dim_dwd_action_userInfo_a` ui
ON uuid.luid = ui.user_id
WHERE ui.user_pseudo_id is not null
GROUP BY 1,2
ORDER BY 1,2