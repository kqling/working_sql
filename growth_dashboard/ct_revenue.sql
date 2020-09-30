MERGE `blockpuzzle-f21e1.warehouse.growth_dashboard_revenue_di` r
USING
    (SELECT
        date,
        case when platform is null then 'All' else platform end as platform,
        ad_revenue,
        iap_revenue
    FROM
        (SELECT
            date,
            platform,
            SUM(ad_revenue) as ad_revenue,
            SUM(iap_revenue) as iap_revenue
        FROM
            (SELECT
                iaa.platform,
                iaa.date,
                iaa.revenue as ad_revenue,
                iap.iap_revenue
            FROM 
                (SELECT 
                    'iOS' as platform,
                    date,
                    SUM(revenue) as revenue
                FROM `foradmobapi.learnings_data_warehouse.dim_dwd_iaa_application_a` app 
                INNER JOIN `foradmobapi.learnings_data_warehouse.fact_dwd_iaa_unitRevenue_di_*` rev
                ON app.app_id = rev.app_id
                AND ifnull(app.platform,'nt') = ifnull(rev.platform,'nt')
                and app.iaa_platform = rev.iaa_platform
                AND app.production_id = '5d0b3f971cd8ea0001e2473a'
                AND rev.date BETWEEN DATE_ADD(@run_date, INTERVAL -4 day) AND DATE_ADD(@run_date, INTERVAL -2 day)
                GROUP BY 1,2) iaa
            LEFT JOIN
                (SELECT 
                    'iOS' as platform,
                    date,
                    SUM(iap.revenue) as iap_revenue
                FROM `foradmobapi.learnings_data_warehouse.dim_dwd_iap_application_a` app
                JOIN `foradmobapi.learnings_data_warehouse.fact_dwd_iap_bill_di_*` iap
                ON iap.app_id = app.app_id
                AND iap.date BETWEEN DATE_ADD(@run_date, INTERVAL -4 day) AND DATE_ADD(@run_date, INTERVAL -2 day)
                AND app.production_id = '5d0b3f971cd8ea0001e2473a'
                GROUP BY 1,2) iap
            ON iap.platform = iaa.platform AND iap.date = iaa.date
            UNION ALL
            SELECT
                iaa.platform,
                iaa.date,
                iaa.revenue as ad_revenue,
                iap.iap_revenue
            FROM 
                (SELECT 
                    'Android' as platform,
                    date,
                    SUM(revenue) as revenue
                FROM `foradmobapi.learnings_data_warehouse.dim_dwd_iaa_application_a` app 
                INNER JOIN `foradmobapi.learnings_data_warehouse.fact_dwd_iaa_unitRevenue_di_*` rev
                ON app.app_id = rev.app_id
                and ifnull(app.platform,'nt') = ifnull(rev.platform,'nt')
                and app.iaa_platform = rev.iaa_platform
                AND app.production_id = '5d0b34d6883d6a000119ed23'
                AND rev.date BETWEEN DATE_ADD(@run_date, INTERVAL -4 day) AND DATE_ADD(@run_date, INTERVAL -2 day)
                GROUP BY 1,2) iaa
            LEFT JOIN
                (SELECT 
                    'Android' as platform,
                    date,
                    SUM(iap.revenue) as iap_revenue
                FROM `foradmobapi.learnings_data_warehouse.dim_dwd_iap_application_a` app
                JOIN `foradmobapi.learnings_data_warehouse.fact_dwd_iap_bill_di_*` iap
                ON iap.app_id = app.app_id
                AND iap.date BETWEEN DATE_ADD(@run_date, INTERVAL -4 day) AND DATE_ADD(@run_date, INTERVAL -2 day)
                AND app.production_id = '5d0b34d6883d6a000119ed23'
                GROUP BY 1,2) iap
            ON iap.platform = iaa.platform AND iap.date = iaa.date)
        GROUP BY ROLLUP(date, platform)
        HAVING date is not null)) n
ON r.date = n.date
AND r.platform = n.platform
WHEN MATCHED THEN
    UPDATE SET ad_revenue = n.ad_revenue,
        iap_revenue = n.iap_revenue
WHEN NOT MATCHED THEN
    INSERT (date, platform, ad_revenue, iap_revenue)
        VALUES(date, platform, ad_revenue, iap_revenue)