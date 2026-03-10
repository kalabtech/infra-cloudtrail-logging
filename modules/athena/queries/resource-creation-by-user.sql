-- Query: Detect all resource creation actions grouped by user
-- Use case: Identify which users are creating resources and what they are creating

SELECT
    useridentity.arn      AS user_arn,
    useridentity.type     AS user_type,
    eventname,
    eventsource,
    awsregion,
    COUNT(*)              AS total_events,
    MIN(eventtime)        AS first_seen,
    MAX(eventtime)        AS last_seen
FROM cloudtrail_logs
WHERE eventname LIKE 'Create%'
    AND timestamp >= date_format(current_date - interval '3' month, '%Y/%m/%d')
    AND timestamp <= date_format(current_date, '%Y/%m/%d')
GROUP BY
    useridentity.arn,
    useridentity.type,
    eventname,
    eventsource,
    awsregion
ORDER BY total_events DESC
LIMIT 100;
