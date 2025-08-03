# CloudWatch Log Metric Filters with Existing CloudTrail Logs

## Overview
This 5-minute demonstration shows how to create metric filters from existing AWS CloudTrail logs in CloudWatch using the AWS Console. You'll learn to transform CloudTrail log events into CloudWatch metrics that can be graphed, monitored, and used for security alerting and operational insights.

## Prerequisites
- AWS account with CloudWatch access
- Existing CloudTrail log group in CloudWatch Logs (trail already configured)
- Basic understanding of AWS CloudTrail log format

## Use Cases for CloudTrail Metric Filters
- Monitor failed login attempts (Console sign-ins)
- Track root account usage
- Alert on resource deletions (EC2, S3, etc.)
- Monitor privilege escalation (IAM policy changes)
- Track API calls from specific IP addresses or users
- Monitor unauthorized access attempts

## Demonstration Steps

### Step 1: Locate Existing CloudTrail Log Group (30 seconds)
1. Open AWS Management Console
2. Navigate to **CloudWatch** service
3. In the left navigation pane, click **Logs** → **Log groups**
4. Find your existing CloudTrail log group (common naming patterns):
   - `/aws/cloudtrail/CloudTrail-LogGroup`
   - `/aws/cloudtrail/management-events`
   - `/aws/cloudtrail/[your-trail-name]`
   - Custom log group names you may have configured
5. Click on the log group name to verify it contains CloudTrail events
6. Note: If you don't see any CloudTrail log groups, verify your trail is configured to send logs to CloudWatch

### Step 2: Examine Existing CloudTrail Log Format (30 seconds)
1. Click on your CloudTrail log group
2. Click on a recent log stream to view actual events
3. Review the JSON structure of your CloudTrail events:
   ```json
   {
     "eventTime": "2024-01-15T10:30:45Z",
     "eventName": "ConsoleLogin",
     "eventSource": "signin.amazonaws.com",
     "userIdentity": {
       "type": "Root",
       "principalId": "123456789012",
       "arn": "arn:aws:iam::123456789012:root"
     },
     "sourceIPAddress": "192.168.1.100",
     "responseElements": {
       "ConsoleLogin": "Success"
     }
   }
   ```
4. Note the specific event types and fields available in your logs

### Step 3: Create Security Metric Filters (3 minutes)

#### Filter 1 - Root Account Usage
1. Go back to the log group and click **Metric filters** tab
2. Click **Create metric filter**
3. Configure the filter:
   ```
   Filter pattern: { $.userIdentity.type = "Root" }
   ```
4. **Test pattern** with sample log data
5. **Metric details**:
   - **Metric namespace**: `CloudTrailMetrics`
   - **Metric name**: `RootAccountUsage`
   - **Metric value**: `1`
   - **Default value**: `0`
6. Click **Create metric filter**

#### Filter 2 - Failed Console Logins
1. Click **Create metric filter** again
2. Configure the filter:
   ```
   Filter pattern: { $.eventName = "ConsoleLogin" && $.responseElements.ConsoleLogin = "Failure" }
   ```
3. **Metric details**:
   - **Metric namespace**: `CloudTrailMetrics`
   - **Metric name**: `FailedConsoleLogins`
   - **Metric value**: `1`
   - **Default value**: `0`
   - **Unit**: `Count`
4. **Add dimension** (optional):
   - **Dimension name**: `SourceIP`
   - **Dimension value**: `$.sourceIPAddress`

#### Filter 3 - Resource Deletions
1. Click **Create metric filter** again
2. Configure the filter:
   ```
   Filter pattern: { $.eventName = Delete* || $.eventName = Terminate* }
   ```
3. **Metric details**:
   - **Metric namespace**: `CloudTrailMetrics`
   - **Metric name**: `ResourceDeletions`
   - **Metric value**: `1`
   - **Default value**: `0`
4. **Add dimension**:
   - **Dimension name**: `EventName`
   - **Dimension value**: `$.eventName`

### Step 4: Verify Metrics with Existing Data (1 minute)
1. Navigate to **CloudWatch** → **Metrics** → **All metrics**
2. Find your custom namespace: `CloudTrailMetrics`
3. Explore the created metrics:
   - `RootAccountUsage`
   - `FailedConsoleLogins`
   - `ResourceDeletions`
4. Click **Graphed metrics** tab to visualize
5. Adjust time range to see historical data from your existing CloudTrail logs
6. Note: Metrics will show data based on events that occurred after filter creation

### Step 5: Monitor Ongoing Activity (1 minute)
Since you have an existing CloudTrail with ongoing activity:
1. **Check recent activity**: Review your log streams for recent events
2. **Wait for new metrics**: New events will automatically populate your metrics
3. **Historical analysis**: Use CloudWatch Logs Insights to analyze patterns in existing data
4. **Optional testing**: Perform actions that would trigger your filters to see real-time updates
5. Note: Metric filters only capture events that occur after the filter is created

## Analyzing Existing CloudTrail Data

Since you're working with existing CloudTrail logs, you can immediately analyze historical patterns:

### Using CloudWatch Logs Insights:
```sql
fields @timestamp, eventName, userIdentity.type, sourceIPAddress
| filter eventName = "ConsoleLogin"
| stats count() by userIdentity.type, responseElements.ConsoleLogin
| sort count desc
```

### Common queries for existing data:
```sql
# Find all root account activity
fields @timestamp, eventName, sourceIPAddress
| filter userIdentity.type = "Root"
| sort @timestamp desc

# Identify failed login patterns
fields @timestamp, sourceIPAddress, errorMessage
| filter eventName = "ConsoleLogin" and responseElements.ConsoleLogin = "Failure"
| stats count() by sourceIPAddress
| sort count desc

# Resource deletion analysis
fields @timestamp, eventName, userIdentity.userName, sourceIPAddress
| filter eventName like /Delete/ or eventName like /Terminate/
| sort @timestamp desc
```

## Advanced CloudTrail Filter Patterns

### IAM Policy Changes:
```json
{ $.eventName = PutUserPolicy || $.eventName = PutRolePolicy || $.eventName = PutGroupPolicy || $.eventName = CreateRole || $.eventName = DeleteRole }
```

### High-Risk API Calls:
```json
{ $.eventName = CreateUser || $.eventName = CreateAccessKey || $.eventName = CreateLoginProfile }
```

### Specific User Activity:
```json
{ $.userIdentity.userName = "suspicious-user" }
```

### API Calls from Specific IP Range:
```json
{ $.sourceIPAddress = 192.168.1.* }
```

### S3 Bucket Policy Changes:
```json
{ $.eventSource = "s3.amazonaws.com" && $.eventName = PutBucketPolicy }
```

### EC2 Security Group Changes:
```json
{ $.eventSource = "ec2.amazonaws.com" && ($.eventName = AuthorizeSecurityGroupIngress || $.eventName = RevokeSecurityGroupIngress) }
```

## Common CloudTrail Event Names for Monitoring

### Authentication Events:
- `ConsoleLogin` - Console sign-in attempts
- `AssumeRole` - Role assumption
- `GetSessionToken` - Temporary credential requests

### IAM Events:
- `CreateUser`, `DeleteUser` - User management
- `AttachUserPolicy`, `DetachUserPolicy` - Permission changes
- `CreateRole`, `DeleteRole` - Role management

### Resource Management:
- `RunInstances`, `TerminateInstances` - EC2 lifecycle
- `CreateBucket`, `DeleteBucket` - S3 bucket management
- `CreateDBInstance`, `DeleteDBInstance` - RDS management

### Security Events:
- `PutBucketPolicy` - S3 bucket policy changes
- `AuthorizeSecurityGroupIngress` - Security group modifications
- `CreateAccessKey`, `DeleteAccessKey` - Access key management

## Best Practices Demonstrated

### Filter Design:
- Use specific JSON path expressions for accuracy
- Test patterns thoroughly with real log data
- Consider case sensitivity in event names
- Use logical operators (&&, ||) for complex conditions

### Metric Organization:
- Group related security metrics in same namespace
- Use descriptive metric names
- Add dimensions for better filtering and analysis
- Set appropriate default values to prevent gaps

### Security Monitoring:
- Monitor privileged account usage (root, admin roles)
- Track authentication failures and patterns
- Alert on resource deletions and policy changes
- Monitor API calls from unusual locations

## Creating CloudWatch Alarms

After creating metrics, set up alarms:

1. **Root Account Usage Alarm**:
   - Threshold: Greater than 0
   - Period: 5 minutes
   - Action: Send SNS notification

2. **Failed Login Attempts**:
   - Threshold: Greater than 5 in 15 minutes
   - Action: Security team notification

3. **Resource Deletion Spike**:
   - Threshold: Greater than 10 in 1 hour
   - Action: Operations team alert

## Troubleshooting Tips

### No Metrics Appearing:
- Verify your CloudTrail log group has recent activity
- Check that metric filters are applied to the correct log group
- Confirm filter pattern matches your actual log format
- Remember: Metrics only capture events after filter creation

### Working with Existing Logs:
- Use CloudWatch Logs Insights to test filter patterns against historical data
- Check log retention settings to understand data availability
- Verify log group permissions if you encounter access issues

### Pattern Testing:
```bash
# Use CloudWatch Logs Insights to test patterns before creating filters
fields @timestamp, eventName, userIdentity.type, sourceIPAddress
| filter eventName = "ConsoleLogin"
| stats count() by userIdentity.type
```

### Common Issues:
- **Case sensitivity**: CloudTrail event names are case-sensitive
- **JSON structure**: Verify exact field paths in your specific CloudTrail logs
- **Historical data**: Metric filters don't retroactively process existing logs
- **Log group selection**: Ensure you're creating filters on the correct log group

## Key Learning Points
- CloudTrail provides rich security and operational data
- JSON filter patterns enable precise event matching
- Metric filters transform logs into actionable metrics
- Dimensions enable detailed analysis and filtering
- Real-time security monitoring requires proper alerting
- Historical analysis helps identify patterns and trends

## Security Benefits
- **Proactive monitoring**: Detect security issues before they escalate
- **Compliance**: Meet audit requirements for access monitoring
- **Incident response**: Quick identification of security events
- **Behavioral analysis**: Understand normal vs. abnormal patterns
- **Automated alerting**: Reduce manual log review overhead

## Integration Opportunities
- Create CloudWatch alarms for immediate notifications
- Export metrics to security information systems
- Build dashboards for security operations centers
- Integrate with AWS Security Hub for centralized monitoring
- Use with AWS Config for compliance monitoring

## Documentation References
- [Creating metrics from log events using filters](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/MonitoringLogData.html)
- [Filter pattern syntax for metric filters](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/FilterAndPatternSyntaxForMetricFilters.html)
- [CloudTrail log file examples](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-log-file-examples.html)
- [Monitoring CloudTrail log files with CloudWatch Logs](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/monitor-cloudtrail-log-files-with-cloudwatch-logs.html)
