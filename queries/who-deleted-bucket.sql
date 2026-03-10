-- Query: Detect S3 bucket deletions
-- Use case: Identify who deleted an S3 bucket and when
-- Table: cloudtrail_logs (Glue Data Catalog)

SELECT
    eventtime,
    eventname,
    useridentity.arn       AS user_arn,
    useridentity.type      AS user_type,
    sourceipaddress,
    awsregion,
    requestparameters
FROM cloudtrail_logs
WHERE eventname = 'DeleteBucket'
AND timestamp >= date_format(current_date - interval '3' month, '%Y/%m/%d')
AND timestamp <= date_format(current_date, '%Y/%m/%d')ORDER BY eventtime DESC
LIMIT 100;
