SELECT
    'Android' as platform,
    u.date,
    u.country,
    map.country_code,
    COUNT(distinct u.user_pseudo_id) as dau,
    COUNT(distinct r1.user_pseudo_id) as D1_active_retended,
    COUNT(distinct case when u.living_days = 0 then u.user_pseudo_id else null end) as new_users,
    COUNT(distinct case when u.living_days = 0 then r1.user_pseudo_id else null end) as D1_new_retended,
    COUNT(distinct case when u.living_days = 0 then r7.user_pseudo_id else null end) as D7_new_retended
FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*` u 
INNER JOIN `blockpuzzle-f21e1.warehouse.xinyao_CountryName_CountryCode_mapping` map
ON u.country = map.country
AND map.country_code in ('US','BR','DE','FR','KR','RU','TR','GB','CA','ES','MX','IT','AU')
LEFT JOIN `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*` r1
ON r1.user_pseudo_id = u.user_pseudo_id
AND r1.date = DATE_ADD(u.date, INTERVAL 1 DAY)
AND r1.date between '2020-08-11' and '2020-08-17'
LEFT JOIN `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*` r7
ON r7.user_pseudo_id = u.user_pseudo_id
AND r7.date = DATE_ADD(u.date, INTERVAL 7 DAY)
AND r7.date between '2020-08-14' and '2020-08-24'
WHERE u.date between '2020-08-10' and '2020-08-16'
GROUP BY 1,2,3,4
UNION ALL
SELECT
    'iOS' as platform,
    u.date,
    u.country,
    map.country_code,
    COUNT(distinct u.user_pseudo_id) as dau,
    COUNT(distinct r1.user_pseudo_id) as D1_active_retended,
    COUNT(distinct case when u.living_days = 0 then u.user_pseudo_id else null end) as new_users,
    COUNT(distinct case when u.living_days = 0 then r1.user_pseudo_id else null end) as D1_new_retended,
    COUNT(distinct case when u.living_days = 0 then r7.user_pseudo_id else null end) as D7_new_retended
FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*` u 
INNER JOIN `blockpuzzle-f21e1.warehouse.xinyao_CountryName_CountryCode_mapping` map
ON u.country = map.country
AND map.country_code in ('US','DE','JP','RU','GB','BR','FR','SA','CA','TR')
LEFT JOIN `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*` r1
ON r1.user_pseudo_id = u.user_pseudo_id
AND r1.date = DATE_ADD(u.date, INTERVAL 1 DAY)
AND r1.date between '2020-08-11' and '2020-08-17'
LEFT JOIN `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*` r7
ON r7.user_pseudo_id = u.user_pseudo_id
AND r7.date = DATE_ADD(u.date, INTERVAL 7 DAY)
AND r7.date between '2020-08-14' and '2020-08-24'
WHERE u.date between '2020-08-10' and '2020-08-16'
GROUP BY 1,2,3,4
ORDER BY 1,2,3,4