SELECT
    'Android' as platform,
    u.date,
    u.country,
    map.country_code,
    COUNT(distinct u.user_pseudo_id) as dau,
    COUNT(distinct case when u.living_days = 0 then u.user_pseudo_id else null end) as new_users
FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*` u 
INNER JOIN `blockpuzzle-f21e1.warehouse.xinyao_CountryName_CountryCode_mapping` map
ON u.country = map.country
AND map.country_code in ('US','BR','DE','FR','KR','RU','TR','GB','CA','ES','MX','IT','AU')
WHERE u.date between '2020-08-17' and '2020-08-23'
GROUP BY 1,2,3,4
UNION ALL
SELECT
    'iOS' as platform,
    u.date,
    u.country,
    map.country_code,
    COUNT(distinct u.user_pseudo_id) as dau,
    COUNT(distinct case when u.living_days = 0 then u.user_pseudo_id else null end) as new_users
FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*` u 
INNER JOIN `blockpuzzle-f21e1.warehouse.xinyao_CountryName_CountryCode_mapping` map
ON u.country = map.country
AND map.country_code in ('US','DE','JP','RU','GB','BR','FR','SA','CA','TR')
WHERE u.date between '2020-08-17' and '2020-08-23'
GROUP BY 1,2,3,4
ORDER BY 1,2,3,4