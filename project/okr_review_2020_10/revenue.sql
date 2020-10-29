SELECT 
    iaa.date,
    case when iaa.country_code = 'US' then 'United States'
        when iaa.country_code = 'GB' then 'United Kingdom'
        when iaa.country_code = 'DE' then 'Germany'
        when iaa.country_code = 'FR' then 'France'
        when iaa.country_code = 'ES' then 'Spain'
        when iaa.country_code = 'RU' then 'Russia'
        when iaa.country_code = 'JP' then 'Japan'
        when iaa.country_code = 'MX' then 'Mexico'
        when iaa.country_code = 'BR' then 'Brazil'
        else 'Other' end as country, 
    SUM(ifnull(iaa.revenue,0) + ifnull(iap.iap_revenue,0)) as total_revenue
FROM 
    (SELECT 
        rev.date,
        country_code, 
        SUM(revenue) as revenue 
    FROM `foradmobapi.learnings_data_warehouse.dim_dwd_iaa_application_a` app 
    INNER JOIN `foradmobapi.learnings_data_warehouse.fact_dwd_iaa_unitRevenue_di_*` rev 
    ON app.app_id = rev.app_id 
    and ifnull(app.platform,'nt') = ifnull(rev.platform,'nt')
    and app.iaa_platform = rev.iaa_platform
    AND app.production_id IN ('5d0b34d6883d6a000119ed23') 
    AND rev.date between '2020-10-21' and '2020-10-27'
    GROUP BY 1,2) iaa 
LEFT JOIN 
    (SELECT
        iap.date,
        country, 
        SUM(iap.revenue) as iap_revenue 
    FROM `foradmobapi.learnings_data_warehouse.dim_dwd_iap_application_a` app 
    JOIN `foradmobapi.learnings_data_warehouse.fact_dwd_iap_bill_di_*` iap 
    ON iap.app_id = app.app_id 
    AND iap.date between '2020-10-21' and '2020-10-27'
    AND app.production_id IN ('5d0b34d6883d6a000119ed23') 
    GROUP BY 1,2) iap 
ON iap.country = iaa.country_code 
AND iap.date = iaa.date
GROUP BY date, country
ORDER BY 1,2
ORDER BY 1,2