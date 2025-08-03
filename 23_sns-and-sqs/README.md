# AWS Foundations Video - Module 23: SNS and SQS Demonstrations

## Overview
This directory contains hands-on demonstrations for Amazon Simple Notification Service (SNS) and Amazon Simple Queue Service (SQS). These demos are designed to provide practical experience with AWS messaging services in a 5-minute format suitable for training sessions.

## Demonstrations Included

### 23.2: Create and Subscribe to SNS Topic (Console)
**Duration**: 5 minutes  
**Tools**: AWS Management Console  
**Services**: Amazon SNS  

Learn how to create an SNS topic and set up email subscriptions using the AWS Console. This demo covers the fundamentals of pub/sub messaging patterns.

**Key Learning Objectives**:
- Create and configure SNS topics
- Set up email subscriptions
- Publish and test message delivery
- Understand SNS topic types (Standard vs FIFO)

### 23.4: Lambda Function with SQS Trigger (Console + Terminal)
**Duration**: 5 minutes  
**Tools**: AWS Management Console, Terminal/AWS CLI  
**Services**: Amazon SQS, AWS Lambda, Amazon CloudWatch  

Build an event-driven architecture by creating a Lambda function that processes messages from an SQS queue. This demo demonstrates serverless message processing patterns.

**Key Learning Objectives**:
- Create SQS queues for message queuing
- Build Lambda functions for message processing
- Configure SQS triggers for Lambda
- Monitor function execution with CloudWatch
- Use AWS CLI for testing and automation

## Architecture Patterns Demonstrated

### Publisher-Subscriber (Pub/Sub) Pattern
The SNS demonstration shows how to implement a pub/sub pattern where:
- Publishers send messages to topics
- Multiple subscribers can receive the same message
- Decoupling between message producers and consumers

### Event-Driven Processing Pattern
The Lambda + SQS demonstration shows how to implement event-driven processing where:
- Messages are queued for reliable processing
- Lambda functions are triggered automatically
- Scalable processing based on queue depth
- Error handling and retry mechanisms

## Prerequisites

Before running these demonstrations, ensure you have:

1. **AWS Account**: Active AWS account with appropriate permissions
2. **AWS CLI**: Installed and configured with credentials
3. **Console Access**: Access to AWS Management Console
4. **Email Access**: Valid email address for SNS subscriptions
5. **Terminal**: Command line access for CLI operations

## Quick Start

1. **Choose a demonstration** based on your learning objectives
2. **Navigate to the subdirectory** for detailed instructions
3. **Follow the README** in each demo directory
4. **Use the provided scripts** for testing and automation

## File Structure

```
23_sns-and-sqs/
├── README.md (this file)
├── 23.2_create-and-subscribe-to-sns-console/
│   ├── README.md
│   └── test_sns_publishing.sh
└── 23.4_lambda-function-with-sqs-trigger-console-terminal/
    ├── README.md
    ├── lambda_function.py
    └── send_test_messages.sh
```

## Best Practices Covered

### Security
- IAM roles and permissions for Lambda execution
- Queue and topic access policies
- Avoiding sensitive information in resource names

### Reliability
- Dead letter queues for error handling
- Message visibility timeouts
- Retry mechanisms and error handling

### Performance
- Batch processing for efficiency
- Appropriate timeout configurations
- Monitoring and logging

### Cost Optimization
- Resource cleanup procedures
- Understanding pricing models
- Efficient message processing patterns

## Integration Scenarios

These demonstrations can be combined to show more complex scenarios:

1. **SNS to SQS Fan-out**: Subscribe SQS queues to SNS topics for message distribution
2. **Multi-stage Processing**: Chain multiple Lambda functions via SQS
3. **Error Handling**: Implement dead letter queues and retry logic
4. **Cross-service Integration**: Connect with other AWS services like S3, DynamoDB

## Troubleshooting

Common issues and solutions:

- **Permission Errors**: Ensure proper IAM roles and policies
- **Message Not Delivered**: Check subscription confirmations and filters
- **Lambda Not Triggering**: Verify SQS trigger configuration and permissions
- **Timeout Issues**: Adjust visibility timeout and Lambda timeout settings

## Additional Resources

- [Amazon SNS Developer Guide](https://docs.aws.amazon.com/sns/latest/dg/)
- [Amazon SQS Developer Guide](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/)
- [AWS Lambda Developer Guide](https://docs.aws.amazon.com/lambda/latest/dg/)
- [AWS CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/)

## Support

For questions or issues with these demonstrations:
1. Check the individual README files in each demo directory
2. Review the AWS documentation links provided
3. Verify your AWS permissions and configuration
4. Test with the provided scripts for debugging

---
*Created for AWS Foundations Training*  
*Module 23: Amazon SNS and Amazon SQS*
