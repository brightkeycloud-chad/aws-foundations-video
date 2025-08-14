# AWS GuardDuty Findings to SNS Delivery Demo

## Overview
This 5-minute demonstration shows how to configure Amazon GuardDuty to deliver findings to Amazon SNS using EventBridge and the AWS Console. You'll set up automated notifications for security findings.

## Prerequisites
- AWS account with appropriate permissions
- Amazon GuardDuty enabled in your region
- Basic understanding of Amazon SNS and EventBridge

## Demo Steps (5 minutes)

### Step 1: Create SNS Topic (1 minute)
1. Navigate to **Amazon SNS** in the AWS Console
2. Click **Create topic**
3. Choose **Standard** topic type
4. Enter topic name: `guardduty-findings-alerts`
5. Leave other settings as default
6. Click **Create topic**
7. Note the **Topic ARN** for later use

### Step 2: Create SNS Subscription (30 seconds)
1. In the SNS topic details page, click **Create subscription**
2. Choose **Protocol**: Email
3. Enter your email address in **Endpoint**
4. Click **Create subscription**
5. Check your email and confirm the subscription

### Step 3: Access Amazon EventBridge (30 seconds)
1. Navigate to **Amazon EventBridge** in the AWS Console
2. Click **Rules** in the left navigation pane
3. Ensure you're on the **default** event bus
4. Click **Create rule**

### Step 4: Configure EventBridge Rule (2 minutes)
1. **Rule details**:
   - Name: `guardduty-findings-to-sns`
   - Description: `Send GuardDuty findings to SNS topic`
   - Event bus: `default`
   - Rule type: `Rule with an event pattern`

2. **Event pattern**:
   - Event source: `AWS services`
   - AWS service: `GuardDuty`
   - Event type: `GuardDuty Finding`
   - Click **Next**

3. **Select targets**:
   - Target type: `AWS service`
   - Select a target: `SNS topic`
   - Topic: Select `guardduty-findings-alerts`
   - Click **Next**

4. **Review and create**:
   - Review the configuration
   - Click **Create rule**

### Step 5: Test the Integration (1 minute)
1. Navigate to **Amazon GuardDuty** console
2. Go to **Settings** → **Sample findings**
3. Click **Generate sample findings**
4. This creates sample findings of different severity levels
5. Wait 1-2 minutes for EventBridge to process the findings
6. Check your email for SNS notifications

**Alternative**: Use the provided script to generate sample findings:
```bash
./generate-sample-findings.sh
```

### Step 6: Verify and Customize (30 seconds)
1. Return to **GuardDuty** → **Findings**
2. View the generated sample findings
3. Show how the EventBridge rule captured these findings
4. Explain how you can customize the rule for specific:
   - Severity levels (HIGH, MEDIUM, LOW)
   - Finding types
   - Specific resources

## Advanced Configuration (Optional)
To filter for only HIGH and CRITICAL severity findings, modify the EventBridge rule pattern:

```json
{
  "source": ["aws.guardduty"],
  "detail-type": ["GuardDuty Finding"],
  "detail": {
    "severity": [{ "numeric": [">=", 7.0] }]
  }
}
```

**GuardDuty Severity Levels** (based on AWS documentation):
- **Critical**: 9.0 - 10.0 (immediate action required)
- **High**: 7.0 - 8.9 (priority remediation)
- **Medium**: 4.0 - 6.9 (investigate at convenience)
- **Low**: 1.0 - 3.9 (informational)

The above pattern captures all findings with severity ≥ 7.0, which includes both HIGH and CRITICAL findings.

## Key Learning Points
- GuardDuty automatically publishes findings to EventBridge
- EventBridge enables real-time processing of security findings
- SNS provides multiple notification channels (email, SMS, HTTP endpoints)
- Rules can be customized to filter findings by severity or type
- Integration enables automated incident response workflows
- Sample findings help test your notification setup

## Automation Scripts (Optional)

For faster setup and testing, use the provided scripts:

### Quick Setup Script
```bash
./create-eventbridge-rule.sh
```
This script automates:
- SNS topic creation
- EventBridge rule configuration
- Target assignment
- Permission setup
- Optional email subscription
- Optional HIGH/CRITICAL severity filtering

### HIGH/CRITICAL Severity Only
```bash
./create-high-severity-rule.sh
```
This script creates a separate rule that only captures HIGH and CRITICAL severity findings (≥ 7.0):
- Creates dedicated SNS topic for urgent alerts
- Uses numeric comparison for precise severity filtering
- Filters out MEDIUM and LOW severity findings

### Sample Findings Generator
```bash
./generate-sample-findings.sh
```
This script:
- Generates multiple sample findings
- Verifies GuardDuty is enabled
- Lists created findings
- Checks EventBridge integration

## Cleanup Script
Run the cleanup script to remove resources created during this demo:

```bash
./cleanup.sh
```

## Additional Resources and Citations

### AWS Documentation References
- [Processing GuardDuty findings with Amazon EventBridge](https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_findings_eventbridge.html)
- [Severity levels of GuardDuty findings](https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_findings-severity.html)
- [Comparison operators for EventBridge event patterns](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-create-pattern-operators.html)
- [What is Amazon GuardDuty?](https://docs.aws.amazon.com/guardduty/latest/ug/what-is-guardduty.html)
- [Viewing generated findings in GuardDuty console](https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_working-with-findings.html)
- [Amazon EventBridge User Guide](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-what-is.html)

### Integration and Automation
- [Invoking Lambda functions with Amazon SNS notifications](https://docs.aws.amazon.com/lambda/latest/dg/with-sns.html)
- [GuardDuty finding aggregation](https://docs.aws.amazon.com/guardduty/latest/ug/finding-aggregation.html)
- [Exporting GuardDuty findings to Amazon S3](https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_exportfindings.html)

### Console Links
- [Amazon GuardDuty Console](https://console.aws.amazon.com/guardduty/)
- [Amazon SNS Console](https://console.aws.amazon.com/sns/)
- [Amazon EventBridge Console](https://console.aws.amazon.com/events/)

---
*Demo Duration: 5 minutes*  
*Last Updated: August 2025*
