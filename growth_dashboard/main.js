function onOpen() {
  var sheet = SpreadsheetApp.getActiveSpreadsheet();
  var menuEntries = [{name: "更新（分析师更新，不要点击）", functionName: "QueryData"}, {name: "test", functionName: "test"}];
  sheet.addMenu('更新报表', menuEntries);
}

function test() {
  var sql = 'SELECT platform, date, active_type, users, start_game_users, game_num, crush_times, crush_rows, duration_min, aha_users \
    FROM `blockpuzzle-f21e1.warehouse.growth_dashboard_raw_di` \
    WHERE date between date_add(current_date(),interval -4 day) and date_add(current_date(),interval -2 day) \
    ORDER BY date, platform, active_type';
  write_sheet(sql, "test");
}


function QueryData() {
  var raw = 'SELECT platform, date, active_type, users, start_game_users, game_num, crush_times, crush_rows, duration_min, aha_users \
    FROM `blockpuzzle-f21e1.warehouse.growth_dashboard_raw_di` \
    WHERE date between date_add(current_date(),interval -4 day) and date_add(current_date(),interval -2 day) \
    ORDER BY date, platform, active_type';
  write_sheet(raw, "raw");
  
  var retention = 'select platform, date, D1_active_retention, D1_new_retention \
    from `blockpuzzle-f21e1.warehouse.growth_dashboard_retention_di` \
    where date between date_add(current_date(),interval -5 day) and date_add(current_date(),interval -3 day) \
    order by date, platform';
  write_sheet(retention, "retention");
  
  var revenue = 'select platform, date, ad_revenue, iap_revenue, ifnull(ad_revenue,0)+ifnull(iap_revenue,0) as total_revenue \
    from `blockpuzzle-f21e1.warehouse.growth_dashboard_revenue_di` \
    where date between date_add(current_date(),interval -4 day) and date_add(current_date(),interval -2 day) \
    order by date, platform';
  write_sheet(revenue, "revenue");
  
  var new_user_by_media_source = 'SELECT \
        case when platform is null then \'All\' else platform end as platform, \
        date, \
        media_source, \
        new_users as users \
    FROM \
        (SELECT \
            date, \
            media_source, \
            platform, \
            SUM(users) as new_users \
        FROM \
            (SELECT \
                \'iOS\' as platform, \
                date, \
                media_source, \
                COUNT(distinct user_pseudo_id) as users \
            FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*` \
            WHERE date between date_add(current_date(),interval -4 day) and date_add(current_date(),interval -2 day) \
            AND living_days = 0 \
            GROUP BY 1,2,3 \
            UNION ALL \
            SELECT \
                \'Android\' as platform, \
                date, \
                media_source, \
                COUNT(distinct user_pseudo_id) as users \
            FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*` \
            WHERE date between date_add(current_date(),interval -4 day) and date_add(current_date(),interval -2 day) \
            AND living_days = 0 \
            GROUP BY 1,2,3) \
        GROUP BY ROLLUP(date, media_source, platform) \
        HAVING date is not null and media_source is not null) \
    ORDER BY date, platform, media_source';
  write_sheet(new_user_by_media_source, "by_media_source");
  
  var revenue_by_country = 'SELECT \
    case when platform is null then \'All\' else platform end as platform, \
    country_code, \
    sum(total_revenue) as total_revenue \
    FROM \
    (SELECT \
        iaa.platform, \
        case when iaa.country_code in (\'US\',\'GB\',\'DE\',\'FR\',\'ES\',\'RU\',\'JP\',\'MX\',\'BR\') then iaa.country_code else \'other\' end as country_code, \
        SUM(ifnull(iaa.revenue,0) + ifnull(iap.iap_revenue,0)) as total_revenue \
    FROM \
        (SELECT \
            country_code, \
            case when app.production_id = \'5d0b34d6883d6a000119ed23\' then \'Android\' else \'iOS\' end as platform, \
            SUM(revenue) as revenue \
        FROM `foradmobapi.learnings_data_warehouse.dim_dwd_iaa_application_a` app \
        INNER JOIN `foradmobapi.learnings_data_warehouse.fact_dwd_iaa_unitRevenue_di_*` rev \
        ON app.app_id = rev.app_id \
        AND app.production_id IN (\'5d0b3f971cd8ea0001e2473a\',\'5d0b34d6883d6a000119ed23\') \
        AND rev.date = DATE_ADD(CURRENT_DATE(), INTERVAL -2 DAY) \
        GROUP BY 1,2) iaa \
    LEFT JOIN \
        (SELECT \
            case when app.production_id = \'5d0b34d6883d6a000119ed23\' then \'Android\' else \'iOS\' end as platform, \
            country, \
            SUM(iap.revenue) as iap_revenue \
        FROM `foradmobapi.learnings_data_warehouse.dim_dwd_iap_application_a` app \
        JOIN `foradmobapi.learnings_data_warehouse.fact_dwd_iap_bill_di_*` iap \
        ON iap.app_id = app.app_id \
        AND iap.date = DATE_ADD(CURRENT_DATE(), INTERVAL -2 DAY) \
        AND app.production_id IN (\'5d0b3f971cd8ea0001e2473a\',\'5d0b34d6883d6a000119ed23\') \
        GROUP BY 1,2) iap \
    ON iap.platform = iaa.platform \
    AND iap.country = iaa.country_code \
    GROUP BY ROLLUP(iaa.country_code, iaa.platform) \
    HAVING iaa.country_code is not null) \
    GROUP BY 1,2 \
    ORDER BY 1,2';
  clear_and_write(revenue_by_country, "rev_country");
  
  var dau_by_country = 'SELECT \
    case when platform is null then \'All\' else platform end as platform, \
    country, \
    SUM(DAU) as DAU \
    FROM \
    (SELECT \
        platform, \
        case when country in (\'United States\',\'United Kingdom\',\'Germany\',\'France\',\'Spain\',\'Russia\',\'Japan\',\'Mexico\',\'Brazil\') then country else \'other\' end as country, \
        SUM(users) as DAU \
    FROM \
        (SELECT \
            \'iOS\' as platform, \
            country, \
            COUNT(distinct user_pseudo_id) as users \
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*` \
        WHERE date = DATE_ADD(CURRENT_DATE(), INTERVAL -2 DAY) \
        GROUP BY 1,2 \
        UNION ALL \
        SELECT \
            \'Android\' as platform, \
            country, \
            COUNT(distinct user_pseudo_id) as users \
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*` \
        WHERE date = DATE_ADD(CURRENT_DATE(), INTERVAL -2 DAY) \
        GROUP BY 1,2) \
    GROUP BY ROLLUP(country, platform) \
    HAVING country is not null) \
    GROUP BY 1,2 \
    ORDER BY 1,2';
  clear_and_write(dau_by_country, "dau_country");
}

