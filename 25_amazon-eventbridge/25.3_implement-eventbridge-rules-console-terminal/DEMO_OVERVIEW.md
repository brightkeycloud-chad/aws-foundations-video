# AWS Health Event Monitor Demo - Component Overview

## 📁 Demo Files

### 📋 Documentation
- **`README.md`** - Complete 5-minute demonstration guide with console and CLI instructions
- **`DEMO_OVERVIEW.md`** - This file, explaining all components

### 🔧 Automation Scripts
- **`provision-health-monitor.sh`** - Automated provisioning of all AWS resources
- **`test-health-event.sh`** - Test script with sample AWS Health events
- **`cleanup.sh`** - Complete cleanup of all created resources

## 🏗️ Architecture Components

### 1. Event Source: AWS Health
- **Purpose**: Generates events for AWS service issues, maintenance, and notifications
- **Event Types**: Operational issues, scheduled maintenance, investigations, account notifications
- **Scope**: Public events (affect all customers) and account-specific events

### 2. Event Router: Amazon EventBridge
- **Rule Name**: `HealthEventRule`
- **Event Pattern**: Captures all AWS Health events (`source: aws.health`)
- **Function**: Routes health events to Lambda function for processing

### 3. Event Processor: AWS Lambda
- **Function Name**: `HealthEventProcessor`
- **Runtime**: Python 3.12
- **Purpose**: 
  - Parses AWS Health event JSON
  - Creates human-readable summaries with emojis and formatting
  - Publishes formatted alerts to SNS topic

### 4. Notification Service: Amazon SNS
- **Topic Name**: `aws-health-alerts`
- **Purpose**: Delivers formatted health alerts via email
- **Subscription**: Email endpoint for receiving notifications

### 5. Monitoring: Amazon CloudWatch
- **Log Group**: `/aws/lambda/HealthEventProcessor`
- **Purpose**: Stores Lambda execution logs for debugging and monitoring

## 🔄 Event Flow

```
AWS Health Service Issues
           ↓
    EventBridge Rule
    (Filter: aws.health)
           ↓
    Lambda Function
    (Parse & Format)
           ↓
      SNS Topic
    (Email Alert)
           ↓
    Human Recipient
```

## 📊 Sample Event Types Tested

### 1. EC2 Operational Issue
- **Category**: Issue
- **Status**: Open
- **Scope**: Public
- **Impact**: Service degradation affecting multiple customers

### 2. RDS Scheduled Maintenance
- **Category**: Scheduled Change
- **Status**: Upcoming
- **Scope**: Account-specific
- **Impact**: Planned maintenance window for specific resources

### 3. S3 Service Issue (Resolved)
- **Category**: Issue
- **Status**: Closed
- **Scope**: Public
- **Impact**: Previously resolved service issue

### 4. Lambda Investigation
- **Category**: Investigation
- **Status**: Open
- **Scope**: Public
- **Impact**: Service team investigating reported issues

## 🎯 Learning Objectives

### Event-Driven Architecture
- **Decoupling**: Services communicate through events, not direct calls
- **Scalability**: System automatically handles varying event volumes
- **Resilience**: Components can fail independently without affecting others

### AWS Service Integration
- **EventBridge**: Central event routing and filtering
- **Lambda**: Serverless event processing
- **SNS**: Reliable message delivery
- **IAM**: Secure service-to-service permissions

### Real-World Application
- **Monitoring**: Automated alerting for service health
- **Operations**: Proactive notification of issues and maintenance
- **Communication**: Human-readable summaries of technical events

## 🔐 Security Considerations

### IAM Permissions
- **Lambda Execution Role**: Minimal permissions for CloudWatch Logs and SNS
- **EventBridge**: Permission to invoke Lambda function
- **SNS**: Publish permissions scoped to specific topic

### Event Filtering
- **Source Filtering**: Only processes events from `aws.health`
- **Type Filtering**: Specifically handles AWS Health Event types
- **Validation**: Lambda function validates event structure

## 🚀 Quick Start Commands

```bash
# 1. Provision all resources
./provision-health-monitor.sh

# 2. Test with sample events
./test-health-event.sh

# 3. Clean up everything
./cleanup.sh
```

## 📈 Monitoring and Troubleshooting

### CloudWatch Logs
```bash
# View recent Lambda logs
aws logs describe-log-streams \
  --log-group-name "/aws/lambda/HealthEventProcessor" \
  --order-by LastEventTime --descending
```

### EventBridge Metrics
- **InvocationsCount**: Number of rule executions
- **SuccessfulInvocations**: Successful Lambda invocations
- **FailedInvocations**: Failed invocations (check Lambda logs)

### SNS Delivery Status
- **NumberOfMessagesPublished**: Messages sent to topic
- **NumberOfNotificationsDelivered**: Successful email deliveries
- **NumberOfNotificationsFailed**: Failed deliveries

## 🔧 Customization Options

### Event Filtering
Modify the EventBridge rule pattern to filter specific event types:
```json
{
    "source": ["aws.health"],
    "detail-type": ["AWS Health Event"],
    "detail": {
        "eventTypeCategory": ["issue"]
    }
}
```

### Notification Channels
Add additional SNS subscriptions:
- SMS notifications
- Slack webhooks
- Microsoft Teams integration
- PagerDuty alerts

### Processing Logic
Enhance Lambda function to:
- Store events in DynamoDB
- Create ServiceNow tickets
- Send to external monitoring systems
- Implement escalation rules

## 📚 Additional Resources

- [AWS Health User Guide](https://docs.aws.amazon.com/health/latest/ug/)
- [EventBridge User Guide](https://docs.aws.amazon.com/eventbridge/latest/userguide/)
- [Lambda Developer Guide](https://docs.aws.amazon.com/lambda/latest/dg/)
- [SNS Developer Guide](https://docs.aws.amazon.com/sns/latest/dg/)

---

**Demo Duration**: 5 minutes  
**Complexity**: Intermediate  
**Cost**: Minimal (within AWS Free Tier for testing)
