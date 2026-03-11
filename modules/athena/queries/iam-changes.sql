-- Query: Detect IAM changes (users, roles, policies)
-- Use case: Identify unauthorized or suspicious IAM modifications

SELECT
    eventtime,
    eventname,
    useridentity.arn      AS user_arn,
    useridentity.type     AS user_type,
    sourceipaddress,
    requestparameters
FROM cloudtrail_logs
WHERE eventsource = 'iam.amazonaws.com'
  AND eventname IN (
      'CreateUser',
      'DeleteUser',
      'AttachUserPolicy',
      'DetachUserPolicy',
      'CreateRole',
      'DeleteRole',
      'AttachRolePolicy',
      'DetachRolePolicy',
      'CreateAccessKey',
      'DeleteAccessKey'
  )
    AND timestamp >= date_format(current_date - interval '3' month, '%Y/%m/%d')
    AND timestamp <= date_format(current_date, '%Y/%m/%d')
ORDER BY eventtime DESC
LIMIT 100;
