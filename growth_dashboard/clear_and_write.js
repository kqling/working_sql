function clear_and_write(sql, SheetName){
  var rows = run_sql(sql)
  if (rows) {
    var spreadsheet = SpreadsheetApp.getActive();
    var sheet = spreadsheet.getSheetByName(SheetName);

    // clear sheet
    var last_row = sheet.getLastRow();
    var cols = rows[0].f;
    sheet.getRange(2, 1, last_row-1, cols.length).clear();
    
    // Append the results.
    var data = new Array(rows.length);
    for (var i = 0; i < rows.length; i++) {
      var cols = rows[i].f;
      data[i] = new Array(cols.length);
      for (var j = 0; j < cols.length; j++) {
        data[i][j] = cols[j].v;
      }
    }
    sheet.getRange(2, 1, rows.length, cols.length).setValues(data);

    Logger.log('Results spreadsheet writed: %s',
        spreadsheet.getUrl());
  } else {
    Logger.log('No rows returned.');
  }
}