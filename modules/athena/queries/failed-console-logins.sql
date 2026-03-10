-- Query: Detect failed AWS console login attempts
-- Use case: Identify brute force or unauthorized access attempts

SELECT
    eventtime,
    useridentity.arn        AS user_arn,
    useridentity.username   AS username,
    sourceipaddress,
    awsregion,
    errormessage
FROM cloudtrail_logs
WHERE eventname = 'ConsoleLogin'
AND errorcode = 'Failed'
    AND timestamp >= date_format(current_date - interval '3' month, '%Y/%m/%d')
    AND timestamp <= date_format(current_date, '%Y/%m/%d')ORDER BY eventtime DESC
ORDER BY eventtime DESC
LIMIT 100;
