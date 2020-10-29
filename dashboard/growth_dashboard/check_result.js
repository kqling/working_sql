function check_result(sql) {
    var rows = run_sql(sql)
    if (rows) {
      
      // Append the results.
      var data = new Array(rows.length);
      for (var i = 0; i < rows.length; i++) {
        var cols = rows[i].f;
        data[i] = new Array(cols.length);
        for (var j = 0; j < cols.length; j++) {
          data[i][j] = cols[j].v;
        }
      }
      
      if (data[0][0] == 'All' && data[1][0] == 'Android' && data[2][0] == 'iOS') {
        Logger.log('Check passed')
        return true
      } else {
        Logger.log('Not enough data in checking') 
      }
    } else {
      Logger.log('No rows returned in checking');
    }
  }
  