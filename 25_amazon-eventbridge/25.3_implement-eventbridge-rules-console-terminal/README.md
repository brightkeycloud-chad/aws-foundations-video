# Amazon EventBridge Rules Implementation Demo
## Event-Driven AWS Health Monitoring (5 minutes)

### Overview
This demonstration shows how to create event-driven architecture using Amazon EventBridge to monitor AWS Health events. The system automatically processes AWS Health notifications, summarizes them in human-readable format, and delivers alerts via SNS.

### Prerequisites
- AWS account with appropriate permissions
- AWS CLI installed and configured
- Basic understanding of Lambda functions and SNS
- Access to AWS Management Console

### Demo Architecture
```
AWS Health Events → EventBridge Rule → Lambda Function → SNS Topic → Email/SMS
```

### Demo Scenario
Create an EventBridge rule that captures all AWS Health events, processes them through a Lambda function that creates human-readable summaries, and sends notifications via SNS.

---

## Part 1: Console Implementation (2.5 minutes)

### Step 1: Create SNS Topic (30 seconds)
1. Navigate to Amazon SNS console at https://console.aws.amazon.com/sns/
2. Click **Create topic**
3. Configure topic:
   - **Type**: Standard
   - **Name**: `aws-health-alerts`
   - **Display name**: `AWS Health Alerts`
4. Click **Create topic**
5. Click **Create subscription**
   - **Protocol**: Email
   - **Endpoint**: Your email address
6. Click **Create subscription** and confirm via email

### Step 2: Create Lambda Function (1.5 minutes)
1. Navigate to AWS Lambda console at https://console.aws.amazon.com/lambda/
2. Click **Create function**
3. Choose **Author from scratch**
4. Configure the function:
   - **Function name**: `HealthEventProcessor`
   - **Runtime**: Python 3.12
   - Leave other settings as default
5. Click **Create function**
6. Replace the default code with the health event processor code (see below)
7. Add environment variable:
   - **Key**: `SNS_TOPIC_ARN`
   - **Value**: Your SNS topic ARN from Step 1
8. Click **Deploy**

### Step 3: Create EventBridge Rule (30 seconds)
1. Navigate to Amazon EventBridge console at https://console.aws.amazon.com/events/
2. Click **Create rule**
3. Configure rule:
   - **Name**: `HealthEventRule`
   - **Description**: `Captures all AWS Health events`
   - **Event bus**: AWS default event bus
   - **Rule type**: Rule with an event pattern
4. Click **Next**
5. Configure event pattern:
   - **Event source**: AWS services
   - **AWS service**: Health
   - **Event type**: All Events
6. Click **Next**
7. Configure target:
   - **Target types**: AWS service
   - **Select a target**: Lambda function
   - **Function**: HealthEventProcessor
8. Click **Next** twice and **Create rule**

---

## Part 2: Automated Provisioning with Bash Script (2.5 minutes)

### Step 1: Run Provisioning Script (1 minute)
```bash
# Make the script executable and run it
chmod +x provision-health-monitor.sh
./provision-health-monitor.sh
```

### Step 2: Test the System (1.5 minutes)
```bash
# Test Lambda function with sample AWS Health event
chmod +x test-health-event.sh
./test-health-event.sh
```

---

## Lambda Function Code

The Lambda function processes AWS Health events and creates human-readable summaries:

```python
import json
import boto3
import os
from datetime import datetime

def lambda_handler(event, context):
    print(f"Received event: {json.dumps(event, indent=2)}")
    
    # Extract health event details
    detail = event.get('detail', {})
    
    # Create human-readable summary
    summary = create_health_summary(detail, event)
    
    # Send to SNS
    send_sns_notification(summary)
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Health event processed successfully',
            'summary': summary
        })
    }

def create_health_summary(detail, event):
    service = detail.get('service', 'Unknown Service')
    event_type = detail.get('eventTypeCode', 'Unknown Event')
    category = detail.get('eventTypeCategory', 'unknown')
    status = detail.get('statusCode', 'unknown')
    region = detail.get('eventRegion', 'unknown')
    scope = detail.get('eventScopeCode', 'unknown')
    
    # Extract description
    descriptions = detail.get('eventDescription', [])
    description = descriptions[0].get('latestDescription', 'No description available') if descriptions else 'No description available'
    
    # Format times
    start_time = detail.get('startTime', 'Unknown')
    end_time = detail.get('endTime', 'Ongoing')
    
    # Count affected resources
    affected_entities = detail.get('affectedEntities', [])
    resource_count = len(affected_entities)
    
    # Create severity indicator
    severity_emoji = get_severity_emoji(category, status)
    
    summary = f"""
🏥 AWS HEALTH ALERT {severity_emoji}

📋 Event Summary:
• Service: {service}
• Event Type: {event_type.replace('_', ' ').title()}
• Category: {category.title()}
• Status: {status.title()}
• Region: {region}
• Scope: {scope.replace('_', ' ').title()}

⏰ Timeline:
• Started: {start_time}
• Ended: {end_time}

📊 Impact:
• Affected Resources: {resource_count}
• Account: {detail.get('affectedAccount', 'Multiple')}

📝 Description:
{description[:500]}{'...' if len(description) > 500 else ''}

🔗 Event ARN:
{detail.get('eventArn', 'N/A')}

Generated at: {datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S UTC')}
    """.strip()
    
    return summary

def get_severity_emoji(category, status):
    if category == 'issue' and status == 'open':
        return '🚨'
    elif category == 'scheduledChange':
        return '📅'
    elif category == 'investigation':
        return '🔍'
    elif status == 'closed':
        return '✅'
    else:
        return '📢'

def send_sns_notification(message):
    sns_topic_arn = os.environ.get('SNS_TOPIC_ARN')
    if not sns_topic_arn:
        print("SNS_TOPIC_ARN environment variable not set")
        return
    
    sns = boto3.client('sns')
    
    try:
        response = sns.publish(
            TopicArn=sns_topic_arn,
            Message=message,
            Subject='AWS Health Event Alert'
        )
        print(f"SNS message sent successfully: {response['MessageId']}")
    except Exception as e:
        print(f"Error sending SNS message: {str(e)}")
```

---

## Testing and Verification

### Manual Testing
Use the provided test script to simulate AWS Health events:
```bash
./test-health-event.sh
```

### Monitor Results
1. **CloudWatch Logs**: Check `/aws/lambda/HealthEventProcessor`
2. **SNS**: Verify email notifications are received
3. **EventBridge**: Monitor rule metrics in the console

### Expected Output
You should receive an email notification with a formatted summary like:
```
🏥 AWS HEALTH ALERT 🚨

📋 Event Summary:
• Service: EC2
• Event Type: Operational Issue
• Category: Issue
• Status: Open
• Region: us-east-1
• Scope: Public

⏰ Timeline:
• Started: Fri, 27 Jan 2023 06:02:51 GMT
• Ended: Ongoing

📊 Impact:
• Affected Resources: 0
• Account: 123456789012

📝 Description:
Current severity level: Operating normally...
```

---

## Cleanup

```bash
# Run cleanup script
chmod +x cleanup.sh
./cleanup.sh
```

---

## Key Learning Points

1. **Event-Driven Architecture**: Real-time processing of AWS service events
2. **Event Filtering**: EventBridge rules can filter events by source, type, and content
3. **Human-Readable Processing**: Lambda transforms technical events into user-friendly notifications
4. **Multi-Service Integration**: EventBridge, Lambda, and SNS work together seamlessly
5. **Monitoring and Alerting**: Automated notification system for AWS service health

---

## Troubleshooting Tips

- **No Events Received**: AWS Health events are rare; use the test script to verify functionality
- **Permission Issues**: Ensure Lambda has SNS publish permissions
- **Email Not Received**: Check spam folder and confirm SNS subscription
- **Lambda Errors**: Check CloudWatch logs for detailed error messages

---

## Citations and Documentation

1. **AWS Health EventBridge Schema**: [Reference: AWS Health events Amazon EventBridge schema](https://docs.aws.amazon.com/health/latest/ug/aws-health-events-eventbridge-schema.html)

2. **AWS Health Events Reference**: [AWS Health events - Amazon EventBridge](https://docs.aws.amazon.com/eventbridge/latest/ref/events-ref-health.html)

3. **EventBridge Event Patterns**: [Amazon EventBridge event patterns](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-patterns.html)

4. **EventBridge User Guide**: [What Is Amazon EventBridge?](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-what-is.html)

5. **AWS Health User Guide**: [What is AWS Health?](https://docs.aws.amazon.com/health/latest/ug/what-is-aws-health.html)

---

**Demo Duration**: 5 minutes  
**Difficulty Level**: Intermediate  
**AWS Services Used**: Amazon EventBridge, AWS Lambda, Amazon SNS, AWS Health
