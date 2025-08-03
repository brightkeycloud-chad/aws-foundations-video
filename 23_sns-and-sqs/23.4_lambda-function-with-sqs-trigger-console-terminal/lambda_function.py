import json
import logging

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    AWS Lambda function to process messages from SQS queue.
    
    This function is triggered when messages arrive in the configured SQS queue.
    It processes each message in the batch and logs the details.
    """
    
    logger.info(f"Received {len(event['Records'])} messages from SQS")
    
    processed_messages = []
    
    for record in event['Records']:
        # Extract message details
        message_body = record['body']
        message_id = record['messageId']
        receipt_handle = record['receiptHandle']
        
        logger.info(f"Processing message ID: {message_id}")
        logger.info(f"Message body: {message_body}")
        
        # Process the message (add your business logic here)
        try:
            # Try to parse as JSON
            message_data = json.loads(message_body)
            logger.info(f"Parsed JSON data: {message_data}")
            
            # Example processing - extract order information
            if 'orderId' in message_data:
                order_id = message_data['orderId']
                customer_id = message_data.get('customerId', 'Unknown')
                amount = message_data.get('amount', 0)
                
                logger.info(f"Processing order {order_id} for customer {customer_id} with amount ${amount}")
                
                # Simulate processing
                processed_messages.append({
                    'messageId': message_id,
                    'orderId': order_id,
                    'status': 'processed'
                })
            else:
                logger.info("Message processed as plain text")
                processed_messages.append({
                    'messageId': message_id,
                    'content': message_body,
                    'status': 'processed'
                })
                
        except json.JSONDecodeError:
            # Handle non-JSON messages
            logger.info(f"Processing non-JSON message: {message_body}")
            processed_messages.append({
                'messageId': message_id,
                'content': message_body,
                'status': 'processed'
            })
        
        except Exception as e:
            logger.error(f"Error processing message {message_id}: {str(e)}")
            # In a real scenario, you might want to send failed messages to a DLQ
            raise e
        
        logger.info(f"Successfully processed message {message_id}")
    
    # Return success response
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': f'Successfully processed {len(processed_messages)} messages',
            'processedMessages': processed_messages
        })
    }
