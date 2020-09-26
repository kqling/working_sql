function write_d7_retention(sql,SheetName) {
    var rows = run_sql(sql)
    if (rows) {
      var spreadsheet = SpreadsheetApp.getActive();
      var sheet = spreadsheet.getSheetByName(SheetName);
  
      // Delete to update data of last two days
      var cols = rows[0].f;
      var last_row = sheet.getLastRow();
      // sheet.getRange(last_row-rows.length/3*2+1, 1, rows.length, cols.length).clear();
      
      // Append the results.
      var data = new Array(rows.length);
      for (var i = 0; i < rows.length; i++) {
        var cols = rows[i].f;
        data[i] = new Array(cols.length-3);
        for (var j = 0; j < cols.length; j++) {
          if (j >= 3) {
          data[i][j-3] = cols[j].v;
          }
        }
      }
      sheet.getRange(last_row-rows.length/3*9+1, cols.length+1, rows.length, cols.length-3).setValues(data);
  
      Logger.log('Results spreadsheet created: %s',
          spreadsheet.getUrl());
    } else {
      Logger.log('No rows returned.');
    }
  }
  