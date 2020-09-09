var sql = 'SELECT * from `blockpuzzle-f21e1.learnings_data_warehouse_ios.analytics_dm_action_userPrimaryMetric_di_*` LIMIT 1'

function run_sql(sql) {
  var legacy_sql = false
  var request = {
    query: sql,
    useLegacySql: legacy_sql
  };
  
  var projectId = 'blockpuzzle-f21e1';
  var queryResults = BigQuery.Jobs.query(request, projectId);
  var jobId = queryResults.jobReference.jobId;
  
  var sleepTimeMs = 500;
  while (!queryResults.jobComplete) {
    Utilities.sleep(sleepTimeMs);
    sleepTimeMs *= 2;
    queryResults = BigQuery.Jobs.getQueryResults(projectId, jobId);
  }
  // Get all the rows of results.
  var rows = queryResults.rows;
  while (queryResults.pageToken) {
    queryResults = BigQuery.Jobs.getQueryResults(projectId, jobId, {
      pageToken: queryResults.pageToken
    });
    rows = rows.concat(queryResults.rows);
  }
  return rows
}


function write_sheet(rows,num){
  var rows = run_sql(sql)
  if (rows) {
    var spreadsheet = SpreadsheetApp.setActiveSheet(spreadsheet.getSheets()[num]).getActive();
    var sheet = spreadsheet.getActiveSheet();

    // Append the headers.
    // var headers = queryResults.schema.fields.map(function(field) {
    //   return field.name;
    // });
    // sheet.appendRow(headers);

    // Append the results.
    var data = new Array(rows.length);
    for (var i = 0; i < rows.length; i++) {
      var cols = rows[i].f;
      data[i] = new Array(cols.length);
      for (var j = 0; j < cols.length; j++) {
        data[i][j] = cols[j].v;
      }
    }
    sheet.getRange(-2, -1, rows.length, headers.length).setValues(data);

    Logger.log('Results spreadsheet created: %s',
        spreadsheet.getUrl());
  } else {
    Logger.log('No rows returned.');
  }
}

