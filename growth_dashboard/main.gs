// 启动表格时初始化快捷执行函数按钮
function onOpen() {
  var sheet = SpreadsheetApp.getActiveSpreadsheet();
  var menuEntries = [{name: "获取BigQuery报表", functionName: "QueryData"}, {name: "清空所有报表", functionName: "clear_all_report"}];
  sheet.addMenu('Load Data', menuEntries);
}



function QueryData() {
  var projectId = 'peace-meditation';
  
  var cfg_sheet =  SpreadsheetApp.getActiveSpreadsheet().getSheetByName("CONFIG");
  var config = cfg_sheet.getRange(1, 1, cfg_sheet.getLastRow(), 2).getValues();

  var start_date = cfg_sheet.getRange(2, 4).getValue();
  var end_date = cfg_sheet.getRange(2, 5).getValue();
  var pre_date = date_interval(start_date, end_date);
  print(pre_date);
  for (i=0;i<config.length;i++) {
    
    var left_index = 2;
    
    if (config[i][1] == true) {
      print(config[i][0])
      clear_item_report('data-' + config[i][0]);
      var tsqls = Array()
      tsqls.push(SQLS['SQL_' + config[i][0]])
      tsqls.push(SQLS['SQL_' + config[i][0] + '_HPOSITION'])
      tsqls.push(SQLS['SQL_' + config[i][0] + '_NPOSITION'])
      for (j=0;j<tsqls.length;j++) {
        if (tsqls[j]) {
          print(tsqls[j])
          var request = {query: pre_date + tsqls[j]}
          var results = BigQuery.Jobs.query(request, projectId);
          var jobId = results.jobReference.jobId;

          var sleepTimeMs = 500;
          while (!results.jobComplete) {
            Utilities.sleep(sleepTimeMs);
            sleepTimeMs *= 2;
            results = BigQuery.Jobs.getQueryResults(projectId, jobId);
          }

          if (results) {
            var dif = write_table_report('data-' + config[i][0], results, left_index);
            left_index = left_index + dif + 3;
          }
        }
      }
    }
  }
  // date_interval('20181001', '20181012')
}

