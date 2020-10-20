SELECT
    b.create_date as bigquery_create_date,
    date(cast(af.event_time as timestamp)) as af_create_date,
    COUNT(distinct case when b.uuid is not null and af.customer_user_id is not null then b.uuid else null end) as both_nu,
    COUNT(distinct case when b.uuid is null and af.customer_user_id is not null then af.customer_user_id else null end) as only_af,
    COUNT(distinct case when b.uuid is not null and af.customer_user_id is null then b.uuid else null end) as only_bigquery
FROM `blockpuzzle-f21e1.warehouse.xinyao_temp_af_bigquery_bigquery_new_user` b
FULL OUTER JOIN `blockpuzzle-f21e1.warehouse.xinyao_temp_af_bigquery_retention_aligning` af 
ON b.uuid = af.customer_user_id
GROUP BY 1,2
ORDER BY 1,2