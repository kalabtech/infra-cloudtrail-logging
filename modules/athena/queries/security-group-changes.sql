-- Query: Detect security group modifications
-- Use case: Identify unauthorized network access rule changes

SELECT
    eventtime,
    eventname,
    useridentity.arn      AS user_arn,
    useridentity.type     AS user_type,
    sourceipaddress,
    awsregion,
    requestparameters
FROM cloudtrail_logs
WHERE eventsource = 'ec2.amazonaws.com'
  AND eventname IN (
      'AuthorizeSecurityGroupIngress',
      'AuthorizeSecurityGroupEgress',
      'RevokeSecurityGroupIngress',
      'RevokeSecurityGroupEgress',
      'CreateSecurityGroup',
      'DeleteSecurityGroup'
  )
    AND timestamp >= date_format(current_date - interval '3' month, '%Y/%m/%d')
    AND timestamp <= date_format(current_date, '%Y/%m/%d')
ORDER BY eventtime DESC
LIMIT 100;
