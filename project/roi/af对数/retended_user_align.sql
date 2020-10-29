SELECT
    nu.create_date,
    COUNT(distinct nu.uuid) as new_user,
    COUNT(distinct br.uuid) as bigquery_retended_user,
    COUNT(distinct af.customer_user_id) as af_retended_user,
    COUNT(distinct case when br.uuid is null and af.customer_user_id is not null then af.customer_user_id else null end) as only_af,
    COUNT(distinct CASE when br.uuid is not null and af.customer_user_id is null then br.uuid else null end) as only_bigquery
FROM
    (SELECT
        b.create_date,
        b.uuid,
        b.user_pseudo_id,
        b.advertising_id,
        af.customer_user_id
    FROM `blockpuzzle-f21e1.warehouse.xinyao_temp_af_bigquery_bigquery_new_user` b
    INNER JOIN `blockpuzzle-f21e1.warehouse.xinyao_temp_af_bigquery_retention_aligning` af 
    ON b.uuid = af.customer_user_id
    AND b.create_date = date(cast(af.event_time as timestamp))) nu
LEFT JOIN 
    (SELECT
        distinct user_pseudo_id,
        create_date,
        uuid,
        country,
        media_source
    FROM `blockpuzzle-f21e1.warehouse.kql_tmp_bq_ret`
    WHERE living_days = 1) br
ON nu.uuid = br.uuid
LEFT JOIN
    (SELECT
        distinct customer_user_id,
        appsflyer_id,
        date(cast(event_time as timestamp)) as event_date
    FROM `blockpuzzle-f21e1.warehouse.xinyao_temp_af_bigquery_af_retended_user`) af
ON nu.uuid = af.customer_user_id
AND af.event_date = date_add(nu.create_date, interval 1 day)
GROUP BY 1
ORDER BY 1