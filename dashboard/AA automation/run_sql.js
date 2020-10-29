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
    
    var headers = queryResults.schema.fields.map(function(field) {
         return field.name;
      });
    return rows
  
  }
  