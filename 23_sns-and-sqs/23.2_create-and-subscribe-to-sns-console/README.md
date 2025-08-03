# Demo 23.2: Create and Subscribe to SNS Topic (Console)

## Overview
This 5-minute demonstration shows how to create an Amazon SNS topic and subscribe an email endpoint using the AWS Management Console. You'll learn the fundamentals of SNS messaging and see how to set up a basic notification system.

## Prerequisites
- AWS account with appropriate permissions
- Access to AWS Management Console
- Valid email address for subscription testing

## Demo Steps (5 minutes)

### Step 1: Create an SNS Topic (2 minutes)

1. **Navigate to SNS Console**
   - Sign in to the [Amazon SNS console](https://console.aws.amazon.com/sns/home)
   - In the navigation panel, choose **Topics**

2. **Create New Topic**
   - Click **Create topic**
   - For **Type**, select **Standard** (explain difference from FIFO)
   - Enter **Name**: `demo-notifications-topic`
   - (Optional) Enter **Display name**: `Demo Notifications`
   - Leave other settings as default for this demo
   - Click **Create topic**

3. **Review Topic Details**
   - Note the Topic ARN that was generated
   - Explain the topic overview page and key settings

### Step 2: Subscribe to the Topic (2 minutes)

1. **Create Email Subscription**
   - On the topic details page, click **Create subscription**
   - For **Protocol**, select **Email**
   - For **Endpoint**, enter a valid email address
   - Click **Create subscription**

2. **Confirm Subscription**
   - Check the email inbox for confirmation message
   - Click the confirmation link in the email
   - Return to console and refresh to see subscription status change to "Confirmed"

### Step 3: Test the Topic (1 minute)

1. **Publish Test Message**
   - Click **Publish message**
   - Enter **Subject**: `Test Notification`
   - Enter **Message body**: `This is a test message from our SNS demo topic.`
   - Click **Publish message**

2. **Verify Delivery**
   - Check email inbox for the delivered message
   - Explain how the message was delivered through SNS

## Key Learning Points

- **SNS Topics**: Act as communication channels for message distribution
- **Standard vs FIFO**: Standard topics provide high throughput, FIFO provides ordering
- **Subscriptions**: Multiple endpoints can subscribe to a single topic
- **Message Delivery**: SNS handles the delivery to all subscribed endpoints

## Cleanup (Optional)

To avoid ongoing costs:
1. Delete the subscription from the topic details page
2. Delete the topic by selecting it and choosing **Delete**

## Additional Considerations

- **Security**: In production, use IAM policies to control access
- **Encryption**: Enable encryption for sensitive data
- **Dead Letter Queues**: Configure for handling failed deliveries
- **Message Filtering**: Use subscription filters for targeted delivery

## Citations

This demonstration is based on the following AWS documentation:

1. [Creating an Amazon SNS topic - Amazon Simple Notification Service](https://docs.aws.amazon.com/sns/latest/dg/sns-create-topic.html)
2. [Subscribing to an Amazon SNS topic - Amazon Simple Notification Service](https://docs.aws.amazon.com/sns/latest/dg/sns-create-subscribe-endpoint-to-topic.html)
3. [Publishing to an Amazon SNS topic - Amazon Simple Notification Service](https://docs.aws.amazon.com/sns/latest/dg/sns-publishing.html)

---
*Demo Duration: 5 minutes*  
*Tools Used: AWS Management Console*  
*Services: Amazon SNS*
