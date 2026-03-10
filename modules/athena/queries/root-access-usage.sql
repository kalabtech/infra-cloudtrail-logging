-- Query: Detect root account usage
-- Use case: Root account should never be used for day-to-day operations.
-- Any root activity is a critical security signal.

SELECT
    eventtime,
    eventname,
    eventsource,
    sourceipaddress,
    awsregion,
    useridentity.type     AS user_type,
    requestparameters
FROM cloudtrail_logs
WHERE useridentity.type = 'Root'
    AND timestamp >= date_format(current_date - interval '3' month, '%Y/%m/%d')
    AND timestamp <= date_format(current_date, '%Y/%m/%d')
ORDER BY eventtime DESC
LIMIT 100;
