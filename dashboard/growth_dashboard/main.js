function onOpen() {
    var sheet = SpreadsheetApp.getActiveSpreadsheet();
    var menuEntries = [{name: "更新（分析师更新，不要点击）", functionName: "main"}, {name: "test", functionName: "test_test"}];
    sheet.addMenu('更新报表', menuEntries);
  }
  
  function test() {
    var test_raw = 'SELECT distinct platform FROM `blockpuzzle-f21e1.warehouse.growth_dashboard_raw_di` WHERE date = DATE_ADD(CURRENT_DATE(), interval -2 day) ORDER BY platform';
    var result_raw = check_result(test_raw);
    if (result_raw) {
      var sql = 'SELECT platform, date, active_type, users, start_game_users, game_num, crush_times, crush_rows, duration_min, aha_users \
      FROM `blockpuzzle-f21e1.warehouse.growth_dashboard_raw_di` \
      WHERE date between date_add(current_date(),interval -4 day) and date_add(current_date(),interval -2 day) \
      ORDER BY date, platform, active_type';
      write_sheet(sql, "test");
    }
  };
  
  
  
  function main() {
    var test_raw = 'SELECT distinct platform FROM `blockpuzzle-f21e1.warehouse.growth_dashboard_raw_di` WHERE date = DATE_ADD(CURRENT_DATE(), interval -2 day) ORDER BY platform';
    var test_retention = 'SELECT distinct platform FROM `blockpuzzle-f21e1.warehouse.growth_dashboard_retention_di` WHERE date = DATE_ADD(CURRENT_DATE(), interval -3 day) ORDER BY platform';
    var test_revenue = 'SELECT distinct platform FROM `blockpuzzle-f21e1.warehouse.growth_dashboard_revenue_di` WHERE date = DATE_ADD(CURRENT_DATE(), interval -2 day) ORDER BY platform';
    var result_raw = check_result(test_raw);
    var result_retention = check_result(test_retention);
    var result_revenue = check_result(test_revenue);
    
    var spreadsheet_test = SpreadsheetApp.getActive();
    var sheet_test = spreadsheet_test.getSheetByName("raw");
    var last_row_test = sheet_test.getLastRow();
    var values = sheet_test.getRange(last_row_test, 1, 1, 1).getValues();
    
    if (result_raw&&result_retention&&result_revenue) {
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
    
      var by_country = 'with dau as ( \
          SELECT \
              date, \
              \'iOS\' as platform, \
              CASE when country in (\'United States\',\'United Kingdom\',\'Germany\',\'France\',\'Spain\',\'Russia\',\'Japan\',\'Mexico\',\'Brazil\') then country else \'other\' end as country, \
              COUNT(distinct user_pseudo_id) as dau, \
              COUNT(distinct CASE when living_days = 0 then user_pseudo_id else null end) as new_users \
          FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*` \
          WHERE date between DATE_ADD(CURRENT_DATE(), INTERVAL -4 DAY) AND DATE_ADD(CURRENT_DATE(), INTERVAL -2 DAY) \
          GROUP BY 1,2,3\
          UNION ALL \
          SELECT \
              date,\
              \'Android\' as platform, \
              CASE when country in (\'United States\',\'United Kingdom\',\'Germany\',\'France\',\'Spain\',\'Russia\',\'Japan\',\'Mexico\',\'Brazil\') then country else \'other\' end as country, \
              COUNT(distinct user_pseudo_id) as dau,\
              COUNT(distinct CASE when living_days = 0 then user_pseudo_id else null end) as new_users\
          FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*` \
          WHERE date between DATE_ADD(CURRENT_DATE(), INTERVAL -4 DAY) AND DATE_ADD(CURRENT_DATE(), INTERVAL -2 DAY) \
          GROUP BY 1,2,3\
      ),\
      rev as (\
          SELECT \
              iaa.date,\
              iaa.platform, \
              case when iaa.country_code = \'US\' then \'United States\'\
                   when iaa.country_code = \'GB\' then \'United Kingdom\'\
                   when iaa.country_code = \'DE\' then \'Germany\'\
                   when iaa.country_code = \'FR\' then \'France\'\
                   when iaa.country_code = \'ES\' then \'Spain\'\
                   when iaa.country_code = \'RU\' then \'Russia\'\
                   when iaa.country_code = \'JP\' then \'Japan\'\
                   when iaa.country_code = \'MX\' then \'Mexico\'\
                   when iaa.country_code = \'BR\' then \'Brazil\'\
                   else \'other\' end as country, \
              SUM(ifnull(iaa.revenue,0) + ifnull(iap.iap_revenue,0)) as total_revenue\
          FROM \
              (SELECT \
                  rev.date,\
                  country_code, \
                  case when app.production_id = \'5d0b34d6883d6a000119ed23\' then \'Android\' else \'iOS\' end as platform, \
                  SUM(revenue) as revenue \
              FROM `foradmobapi.learnings_data_warehouse.dim_dwd_iaa_application_a` app \
              INNER JOIN `foradmobapi.learnings_data_warehouse.fact_dwd_iaa_unitRevenue_di_*` rev \
              ON app.app_id = rev.app_id \
              and ifnull(app.platform,\'nt\') = ifnull(rev.platform,\'nt\')\
              and app.iaa_platform = rev.iaa_platform\
              AND app.production_id IN (\'5d0b3f971cd8ea0001e2473a\',\'5d0b34d6883d6a000119ed23\') \
              AND rev.date between DATE_ADD(CURRENT_DATE(), INTERVAL -4 DAY) AND DATE_ADD(CURRENT_DATE(), INTERVAL -2 DAY) \
              GROUP BY 1,2,3) iaa \
          LEFT JOIN \
              (SELECT\
                  iap.date,\
                  case when app.production_id = \'5d0b34d6883d6a000119ed23\' then \'Android\' else \'iOS\' end as platform, \
                  country, \
                  SUM(iap.revenue) as iap_revenue \
              FROM `foradmobapi.learnings_data_warehouse.dim_dwd_iap_application_a` app \
              JOIN `foradmobapi.learnings_data_warehouse.fact_dwd_iap_bill_di_*` iap \
              ON iap.app_id = app.app_id \
              AND iap.date between DATE_ADD(CURRENT_DATE(), INTERVAL -4 DAY) AND DATE_ADD(CURRENT_DATE(), INTERVAL -2 DAY) \
              AND app.production_id IN (\'5d0b3f971cd8ea0001e2473a\',\'5d0b34d6883d6a000119ed23\') \
              GROUP BY 1,2,3) iap \
          ON iap.platform = iaa.platform \
          AND iap.country = iaa.country_code \
          AND iap.date = iaa.date\
          GROUP BY date, country, iaa.platform\
      ) \
      SELECT\
          date,\
          CASE when platform is null then \'All\' else platform end as platform,\
          CASE when country is null then \'All\' else country end as country,\
          dau,\
          new_users,\
          total_revenue,\
          cast(total_revenue as float64)/dau as arpu\
      FROM\
          (SELECT\
              dau.date,\
              dau.platform,\
              dau.country,\
              SUM(dau.dau) as dau,\
              SUM(dau.new_users) as new_users,\
              SUM(rev.total_revenue) as total_revenue\
          FROM dau dau\
          LEFT JOIN rev rev\
          ON dau.platform = rev.platform\
          AND dau.country = rev.country\
          AND dau.date = rev.date\
          GROUP BY ROLLUP(date, country, platform)\
          HAVING date is not null)\
      UNION all\
      SELECT\
          dau.date,\
          dau.platform,\
          \'All\' as country,\
          SUM(dau.dau) as dau,\
          SUM(dau.new_users) as new_users,\
          SUM(rev.total_revenue) as total_revenue,\
          cast(SUM(rev.total_revenue) as float64)/SUM(dau.dau) as arpu\
      FROM dau dau\
      LEFT JOIN rev rev\
      ON dau.platform = rev.platform\
      AND dau.country = rev.country\
      AND dau.date = rev.date\
      GROUP BY 1,2,3\
      order by date, platform, country';
      write_sheet(by_country, "by_country");
      
      var retention_by_country = 'SELECT\
          date,\
          platform,\
          country,\
          cast(active_retended as float64)/active_users as D7_active_retention,\
          cast(new_retended as float64)/new_users as D7_new_retention\
      FROM\
          (SELECT\
              date,\
              platform,\
              country,\
              SUM(active_users) as active_users,\
              SUM(active_retended) as active_retended,\
              SUM(new_users) as new_users,\
              SUM(new_retended) as new_retended\
          FROM\
              (SELECT\
                  u.platform,\
                  u.date,\
                  u.country,\
                  COUNT(distinct u.user_pseudo_id) as active_users,\
                  COUNT(distinct r.user_pseudo_id) as active_retended,\
                  COUNT(distinct case when u.user_type = \'new\' then u.user_pseudo_id else null end) as new_users,\
                  COUNT(distinct CASE when u.user_type = \'new\' then r.user_pseudo_id else null end) as new_retended\
              FROM\
                  (SELECT\
                      distinct \'iOS\' as platform,\
                      date,\
                      CASE when living_days = 0 then \'new\' else \'old\' end as user_type,\
                      case when country in (\'United States\',\'United Kingdom\',\'Germany\',\'France\',\'Spain\',\'Russia\',\'Japan\',\'Mexico\',\'Brazil\') then country else \'other\' end as country,\
                      user_pseudo_id\
                  FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*`\
                  WHERE date BETWEEN DATE_ADD(CURRENT_DATE(), INTERVAL -5 DAY) AND DATE_ADD(CURRENT_DATE(), INTERVAL -3 DAY)) u \
              LEFT JOIN\
                  (SELECT\
                      distinct date, user_pseudo_id\
                  FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*`\
                  WHERE date BETWEEN DATE_ADD(CURRENT_DATE(), INTERVAL -4 DAY) AND DATE_ADD(CURRENT_DATE(), INTERVAL -2 DAY)) r\
              ON u.user_pseudo_id = r.user_pseudo_id\
              AND r.date = DATE_ADD(u.date, INTERVAL 1 DAY)\
              GROUP BY 1,2,3\
              UNION ALL\
              SELECT\
                  u.platform,\
                  u.date,\
                  u.country,\
                  COUNT(distinct u.user_pseudo_id) as active_users,\
                  COUNT(distinct r.user_pseudo_id) as active_retended,\
                  COUNT(distinct case when u.user_type = \'new\' then u.user_pseudo_id else null end) as new_users,\
                  COUNT(distinct CASE when u.user_type = \'new\' then r.user_pseudo_id else null end) as new_retended\
              FROM\
                  (SELECT\
                      distinct \'Android\' as platform,\
                      date,\
                      case when country in (\'United States\',\'United Kingdom\',\'Germany\',\'France\',\'Spain\',\'Russia\',\'Japan\',\'Mexico\',\'Brazil\') then country else \'other\' end as country,\
                      CASE when living_days = 0 then \'new\' else \'old\' end as user_type,\
                      user_pseudo_id\
                  FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`\
                  WHERE date BETWEEN DATE_ADD(CURRENT_DATE(), INTERVAL -5 DAY) AND DATE_ADD(CURRENT_DATE(), INTERVAL -3 DAY)) u \
              LEFT JOIN\
                  (SELECT\
                      distinct date, user_pseudo_id\
                  FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`\
                  WHERE date BETWEEN DATE_ADD(CURRENT_DATE(), INTERVAL -4 DAY) AND DATE_ADD(CURRENT_DATE(), INTERVAL -2 DAY)) r\
              ON u.user_pseudo_id = r.user_pseudo_id\
              AND r.date = DATE_ADD(u.date, INTERVAL 1 DAY)\
              GROUP BY 1,2,3)\
          GROUP BY date, platform,3)\
      order by 1,2,3';
      write_sheet(retention_by_country, "retention_by_country");
      
      var d7_retention_by_country = 'SELECT\
          date,\
          platform,\
          country,\
          cast(active_retended as float64)/active_users as D1_active_retention,\
          cast(new_retended as float64)/new_users as D1_new_retention\
      FROM\
          (SELECT\
              date,\
              platform,\
              country,\
              SUM(active_users) as active_users,\
              SUM(active_retended) as active_retended,\
              SUM(new_users) as new_users,\
              SUM(new_retended) as new_retended\
          FROM\
              (SELECT\
                  u.platform,\
                  u.date,\
                  u.country,\
                  COUNT(distinct u.user_pseudo_id) as active_users,\
                  COUNT(distinct r.user_pseudo_id) as active_retended,\
                  COUNT(distinct case when u.user_type = \'new\' then u.user_pseudo_id else null end) as new_users,\
                  COUNT(distinct CASE when u.user_type = \'new\' then r.user_pseudo_id else null end) as new_retended\
              FROM\
                  (SELECT\
                      distinct \'iOS\' as platform,\
                      date,\
                      CASE when living_days = 0 then \'new\' else \'old\' end as user_type,\
                      case when country in (\'United States\',\'United Kingdom\',\'Germany\',\'France\',\'Spain\',\'Russia\',\'Japan\',\'Mexico\',\'Brazil\') then country else \'other\' end as country,\
                      user_pseudo_id\
                  FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*`\
                  WHERE date BETWEEN DATE_ADD(CURRENT_DATE(), INTERVAL -11 DAY) AND DATE_ADD(CURRENT_DATE(), INTERVAL -9 DAY)) u \
              LEFT JOIN\
                  (SELECT\
                      distinct date, user_pseudo_id\
                  FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*`\
                  WHERE date BETWEEN DATE_ADD(CURRENT_DATE(), INTERVAL -4 DAY) AND DATE_ADD(CURRENT_DATE(), INTERVAL -2 DAY)) r\
              ON u.user_pseudo_id = r.user_pseudo_id\
              AND r.date = DATE_ADD(u.date, INTERVAL 7 DAY)\
              GROUP BY 1,2,3\
              UNION ALL\
              SELECT\
                  u.platform,\
                  u.date,\
                  u.country,\
                  COUNT(distinct u.user_pseudo_id) as active_users,\
                  COUNT(distinct r.user_pseudo_id) as active_retended,\
                  COUNT(distinct case when u.user_type = \'new\' then u.user_pseudo_id else null end) as new_users,\
                  COUNT(distinct CASE when u.user_type = \'new\' then r.user_pseudo_id else null end) as new_retended\
              FROM\
                  (SELECT\
                      distinct \'Android\' as platform,\
                      date,\
                      case when country in (\'United States\',\'United Kingdom\',\'Germany\',\'France\',\'Spain\',\'Russia\',\'Japan\',\'Mexico\',\'Brazil\') then country else \'other\' end as country,\
                      CASE when living_days = 0 then \'new\' else \'old\' end as user_type,\
                      user_pseudo_id\
                  FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`\
                  WHERE date BETWEEN DATE_ADD(CURRENT_DATE(), INTERVAL -11 DAY) AND DATE_ADD(CURRENT_DATE(), INTERVAL -9 DAY)) u \
              LEFT JOIN\
                  (SELECT\
                      distinct date, user_pseudo_id\
                  FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`\
                  WHERE date BETWEEN DATE_ADD(CURRENT_DATE(), INTERVAL -4 DAY) AND DATE_ADD(CURRENT_DATE(), INTERVAL -2 DAY)) r\
              ON u.user_pseudo_id = r.user_pseudo_id\
              AND r.date = DATE_ADD(u.date, INTERVAL 7 DAY)\
              GROUP BY 1,2,3)\
          GROUP BY date, platform,3)\
      order by 1,2,3';
      write_d7_retention(d7_retention_by_country,"retention_by_country");
      
      
      var d7_retention = 'SELECT\
          date,\
          case when platform is null then \'All\' else platform end as platform,\
          \'All\' as country, \
          cast(active_retended as float64)/active_users as D1_active_retention,\
          cast(new_retended as float64)/new_users as D1_new_retention\
      FROM\
          (SELECT\
              date,\
              platform,\
              SUM(active_users) as active_users,\
              SUM(active_retended) as active_retended,\
              SUM(new_users) as new_users,\
              SUM(new_retended) as new_retended\
          FROM\
              (SELECT\
                  u.platform,\
                  u.date,\
                  COUNT(distinct u.user_pseudo_id) as active_users,\
                  COUNT(distinct r.user_pseudo_id) as active_retended,\
                  COUNT(distinct case when u.user_type = \'new\' then u.user_pseudo_id else null end) as new_users,\
                  COUNT(distinct CASE when u.user_type = \'new\' then r.user_pseudo_id else null end) as new_retended\
              FROM\
                  (SELECT\
                      distinct \'iOS\' as platform,\
                      date,\
                      CASE when living_days = 0 then \'new\' else \'old\' end as user_type,\
                      user_pseudo_id\
                  FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*`\
                  WHERE date BETWEEN DATE_ADD(CURRENT_DATE(), interval -11 DAY) AND DATE_ADD(CURRENT_DATE(), interval -9 DAY)) u \
              LEFT JOIN\
                  (SELECT\
                      distinct date, user_pseudo_id\
                  FROM `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*`\
                  WHERE date BETWEEN DATE_ADD(CURRENT_DATE(), interval -4 DAY) AND DATE_ADD(CURRENT_DATE(), interval -2 DAY)) r\
              ON u.user_pseudo_id = r.user_pseudo_id\
              AND r.date = DATE_ADD(u.date, INTERVAL 7 DAY)\
              GROUP BY 1,2\
              UNION ALL\
              SELECT\
                  u.platform,\
                  u.date,\
                  COUNT(distinct u.user_pseudo_id) as active_users,\
                  COUNT(distinct r.user_pseudo_id) as active_retended,\
                  COUNT(distinct case when u.user_type = \'new\' then u.user_pseudo_id else null end) as new_users,\
                  COUNT(distinct CASE when u.user_type = \'new\' then r.user_pseudo_id else null end) as new_retended\
              FROM\
                  (SELECT\
                      distinct \'Android\' as platform,\
                      date,\
                      CASE when living_days = 0 then \'new\' else \'old\' end as user_type,\
                      user_pseudo_id\
                  FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`\
                  WHERE date BETWEEN DATE_ADD(CURRENT_DATE(), interval -11 DAY) AND DATE_ADD(CURRENT_DATE(), interval -9 DAY)) u \
              LEFT JOIN\
                  (SELECT\
                      distinct date, user_pseudo_id\
                  FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*`\
                  WHERE date BETWEEN DATE_ADD(CURRENT_DATE(), interval -4 DAY) AND DATE_ADD(CURRENT_DATE(), interval -2 DAY)) r\
              ON u.user_pseudo_id = r.user_pseudo_id\
              AND r.date = DATE_ADD(u.date, INTERVAL 7 DAY)\
              GROUP BY 1,2)\
          GROUP BY ROLLUP(date, platform)\
          HAVING date is not null)\
      ORDER BY 1,2';
      write_d7_retention(d7_retention,"retention");
      
    }
  }