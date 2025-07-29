import json
import logging
from datetime import datetime, timezone

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Basic Lambda function that calculates area from length and width
    and demonstrates fundamental Lambda concepts.
    """
    
    # Log the incoming event
    logger.info(f"Received event: {json.dumps(event)}")
    
    try:
        # Extract length and width from the event
        length = event.get('length', 0)
        width = event.get('width', 0)
        
        # Validate inputs
        if not isinstance(length, (int, float)) or not isinstance(width, (int, float)):
            raise ValueError("Length and width must be numeric values")
        
        if length <= 0 or width <= 0:
            raise ValueError("Length and width must be positive values")
        
        # Calculate area
        area = length * width
        
        # Log the calculation
        logger.info(f"Calculated area: {area} (length: {length}, width: {width})")
        
        # Return response
        response = {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Area calculated successfully',
                'input': {
                    'length': length,
                    'width': width
                },
                'result': {
                    'area': area,
                    'unit': 'square units'
                },
                'log_group': context.log_group_name if context else 'N/A'
            })
        }
        
        return response
        
    except Exception as e:
        logger.error(f"Error processing request: {str(e)}")
        
        return {
            'statusCode': 400,
            'body': json.dumps({
                'error': str(e),
                'message': 'Failed to calculate area'
            })
        }
