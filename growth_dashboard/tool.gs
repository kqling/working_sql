// 为String类型增加 format 占位符功能
String.prototype.format=function() {
  // string type add format func
  if(arguments.length==0) return this;
  for(var s=this, i=0; i<arguments.length; i++)
    s=s.replace(new RegExp("\\{"+i+"\\}","g"), arguments[i]);
  return s;
}


// 为Array类型增加 insert 插入固定位置功能
// Array.prototype.insert = function () {
//   if(arguments.length != 2) return this;
//   index = arguments[0];
//   item = arguments[1]
//   this.splice(index, 0, item);
//   return this
// };


// 调试用打印
function print(obj) {
  // printf
  Logger.log(obj)
  // Logger.log("")
}



function date_interval(sdate, edate) {
   res = "#standardSQL\n \
CREATE TEMPORARY FUNCTION start_date() \
RETURNS STRING \
LANGUAGE js AS ''' \
return '" + sdate + "'; \
''';  \
CREATE TEMPORARY FUNCTION end_date() \
RETURNS STRING \
LANGUAGE js AS ''' \
return '" + edate + "'; \
''';  \
";
    return res;
}


function clear_all_report() {
  var ignores = ["CONFIG", "ID-Name"]
  var sheets =  SpreadsheetApp.getActiveSpreadsheet().getSheets();
  for (i=0;i<sheets.length;i++) {
    if (ignores.indexOf(sheets[i].getName()) == -1) {
      var tgt = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(sheets[i].getName());
      tgt.clear();
    }

  }

}


function clear_item_report(sheetName) {
  var ignores = ["CONFIG", "ID-Name"]
  var sheets =  SpreadsheetApp.getActiveSpreadsheet().getSheets();
  if (ignores.indexOf(sheetName) == -1) {
      var tgt = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(sheetName);
    if (tgt) {
      tgt.clear();
    }
  }
}


function write_table_report(sheet_name, report, col_index) {
  var rows = report.rows;
  if (rows == undefined) {
    return 0
  }
  var headers = report.schema.fields.map(function(field) {
    return field.name;
  });
  var data = new Array(rows.length);
  for (var i = 0; i < rows.length; i++) {
    var cols = rows[i].f;
    data[i] = new Array(cols.length);
    for (var j = 0; j < cols.length; j++) {
      data[i][j] = cols[j].v;
    }
  }
  var sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(sheet_name);
  print(headers)
  sheet.getRange(1, col_index, 1, headers.length).setValues([headers]);
  sheet.getRange(2, col_index, rows.length, headers.length).setValues(data);
  return headers.length
}


