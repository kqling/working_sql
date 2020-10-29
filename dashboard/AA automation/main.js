function onOpen() {
    var sheet = SpreadsheetApp.getActiveSpreadsheet();
    var menuEntries = [{name: "run", functionName: "main"}];
    sheet.addMenu('run', menuEntries);
  }
  
function main() {
  
  //get test name
  var spreadsheet = SpreadsheetApp.getActive();
  var sheet = spreadsheet.getSheetByName("dashboard");
  var control = sheet.getRange('C11').getValue();
  var test = sheet.getRange('C12').getValue();
  
  //get date and format to YYYY-mm-dd
  var start_date = sheet.getRange('C13').getValue();
  var start_date = Utilities.formatDate(new Date(start_date), "GMT+8", "yyyy-MM-dd");
  var end_date = sheet.getRange('C14').getValue();
  var end_date = Utilities.formatDate(new Date(end_date), "GMT+8", "yyyy-MM-dd");
  
  //get app_version and country
  var app_version = sheet.getRange('C15').getValue();
  var country = sheet.getRange('C16').getValue();
  
  var raw = 'SELECT \
        u.date, \
        u.ab_group, \
        COUNT(distinct u.user_pseudo_id) as users, \
        cast(SUM(duration) as float64)/60000 as duration_min, \
        SUM(game_num) as game_num, \
        SUM(rewarded_show) as rewarded_show, \
        SUM(inter_show) as inter_show, \
        COUNT(distinct r.user_pseudo_id) as D1_retended_users, \
        COUNT(distinct r5.user_pseudo_id) as D5_retended_users, \
        COUNT(distinct case when u.living_days = 0 then u.user_pseudo_id else null end) as new_users, \
        COUNT(distinct CASE when u.living_days = 0 then r.user_pseudo_id else null end) as D1_new_retended, \
        COUNT(distinct CASE when u.living_days = 0 then r5.user_pseudo_id else null end) as D5_new_retended \
    FROM \
        (SELECT \
            date, \
            CASE when abtest_tag like \'%' + control + '%\' then \'control\' when abtest_tag like \'%' + test + '%\' then \'test\' end as ab_group, \
            user_pseudo_id, \
            living_days, \
            SUM(duration) as duration, \
            SUM(game_num) as game_num, \
            SUM(inter_show) as inter_show, \
            SUM(rewarded_show) as rewarded_show \
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*` \
        WHERE date between \'' + start_date + '\' and \'' + end_date + '\' '
    
  var part_2 = 'AND (abtest_tag like \'%' + control + '%\' or abtest_tag like \'%' + test + '%\') \
        GROUP BY 1,2,3,4) u \
    LEFT JOIN \
        (SELECT \
            distinct date, \
            user_pseudo_id \
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*` \
        WHERE date between \'' + start_date + '\' and \'' + end_date + '\' \
        AND (abtest_tag like \'%' + control + '%\' or abtest_tag like \'%' + test + '%\')) r \
    ON r.date = DATE_ADD(u.date, interval 1 day) \
    AND r.user_pseudo_id = u.user_pseudo_id \
    LEFT JOIN \
        (SELECT \
            distinct date, \
            user_pseudo_id \
        FROM `blockpuzzle-f21e1.learnings_data_warehouse_android.analytics_dm_action_userPrimaryMetric_di_*` \
        WHERE date between \'' + start_date + '\' and \'' + end_date + '\' \
        AND (abtest_tag like \'%' + control + '%\' or abtest_tag like \'%' + test + '%\')) r5 \
    ON r5.date = DATE_ADD(u.date, interval 5 day) \
    AND r5.user_pseudo_id = u.user_pseudo_id \
    GROUP BY 1,2 \
    ORDER BY 1,2';
  
  if (app_version) {
    var raw = raw + 'AND app_version >= \'' + app_version + '\' '
  }
  if (country) {
    var raw = raw + 'AND country = \'' + country + '\' '
  }
  
  var raw = raw + part_2
  Logger.log(raw);
  
  clear_and_write(raw, "raw");
  
}