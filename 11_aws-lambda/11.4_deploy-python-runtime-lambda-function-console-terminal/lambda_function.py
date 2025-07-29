import json
import boto3
from datetime import datetime, timezone, timedelta
import logging

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Lambda function that demonstrates working with AWS Cost Explorer API.
    Retrieves current monthly billing information and stores summary in S3.
    """
    
    logger.info(f"Function started at {datetime.now(timezone.utc).isoformat()}")
    logger.info(f"Received event: {json.dumps(event)}")
    
    try:
        # Extract parameters from event
        bucket_name = event.get('bucket_name')
        granularity = event.get('granularity', 'MONTHLY')  # DAILY, MONTHLY
        group_by = event.get('group_by', 'SERVICE')  # SERVICE, DIMENSION, etc.
        
        if not bucket_name:
            raise ValueError("bucket_name is required in the event")
        
        # Initialize AWS clients
        ce_client = boto3.client('ce')  # Cost Explorer
        s3_client = boto3.client('s3')
        
        # Calculate date range for current month
        now = datetime.now(timezone.utc)
        start_of_month = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
        
        # For monthly granularity, we need at least a month range
        if granularity == 'MONTHLY':
            # Get current month and next month for proper range
            if now.month == 12:
                end_date = now.replace(year=now.year + 1, month=1, day=1)
            else:
                end_date = now.replace(month=now.month + 1, day=1)
        else:
            # For daily, use current date + 1 day
            end_date = now + timedelta(days=1)
        
        start_date_str = start_of_month.strftime('%Y-%m-%d')
        end_date_str = end_date.strftime('%Y-%m-%d')
        
        logger.info(f"Querying Cost Explorer from {start_date_str} to {end_date_str}")
        
        # Call Cost Explorer API
        response = ce_client.get_cost_and_usage(
            TimePeriod={
                'Start': start_date_str,
                'End': end_date_str
            },
            Granularity=granularity,
            Metrics=['BlendedCost', 'UnblendedCost', 'UsageQuantity'],
            GroupBy=[
                {
                    'Type': 'DIMENSION',
                    'Key': group_by
                }
            ]
        )
        
        logger.info("Successfully retrieved cost data from Cost Explorer")
        
        # Process the cost data
        cost_summary = process_cost_data(response, start_date_str, end_date_str)
        
        # Add function metadata
        cost_summary['function_info'] = {
            'function_name': context.function_name,
            'request_id': context.aws_request_id,
            'log_group': context.log_group_name,
            'query_timestamp': datetime.now(timezone.utc).isoformat(),
            'query_parameters': {
                'granularity': granularity,
                'group_by': group_by,
                'date_range': f"{start_date_str} to {end_date_str}"
            }
        }
        
        # Store in S3
        s3_key = f"cost-data/monthly-bill-{datetime.now(timezone.utc).strftime('%Y%m%d-%H%M%S')}.json"
        
        s3_client.put_object(
            Bucket=bucket_name,
            Key=s3_key,
            Body=json.dumps(cost_summary, indent=2, default=str),
            ContentType='application/json'
        )
        
        logger.info(f"Successfully stored cost data in S3: s3://{bucket_name}/{s3_key}")
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Monthly billing data retrieved successfully',
                's3_location': f"s3://{bucket_name}/{s3_key}",
                'billing_summary': {
                    'current_month_total': cost_summary['summary']['total_cost'],
                    'currency': cost_summary['summary']['currency'],
                    'period': cost_summary['summary']['period'],
                    'top_services': cost_summary['summary']['top_services'][:3]  # Top 3 services
                },
                'query_info': {
                    'granularity': granularity,
                    'group_by': group_by,
                    'date_range': f"{start_date_str} to {end_date_str}"
                },
                'timestamp': cost_summary['function_info']['query_timestamp']
            })
        }
        
    except Exception as e:
        logger.error(f"Function execution failed: {str(e)}")
        
        # Check if it's a permissions error
        if 'AccessDenied' in str(e) or 'UnauthorizedOperation' in str(e):
            return {
                'statusCode': 403,
                'body': json.dumps({
                    'error': 'Insufficient permissions for Cost Explorer API',
                    'details': str(e),
                    'required_permissions': [
                        'ce:GetCostAndUsage',
                        'ce:GetDimensionValues',
                        's3:PutObject'
                    ]
                })
            }
        
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': 'Internal server error',
                'details': str(e)
            })
        }

def process_cost_data(cost_response, start_date, end_date):
    """
    Process the Cost Explorer API response into a structured summary.
    """
    
    results_by_time = cost_response.get('ResultsByTime', [])
    
    total_cost = 0.0
    currency = 'USD'  # Default
    service_costs = {}
    
    # Process each time period (usually just one for monthly)
    for time_period in results_by_time:
        period_start = time_period.get('TimePeriod', {}).get('Start')
        period_end = time_period.get('TimePeriod', {}).get('End')
        
        # Get total cost for this period
        period_total = float(time_period.get('Total', {}).get('BlendedCost', {}).get('Amount', 0))
        total_cost += period_total
        
        # Get currency (should be consistent)
        currency = time_period.get('Total', {}).get('BlendedCost', {}).get('Unit', 'USD')
        
        # Process groups (services)
        for group in time_period.get('Groups', []):
            service_name = group.get('Keys', ['Unknown'])[0]
            service_cost = float(group.get('Metrics', {}).get('BlendedCost', {}).get('Amount', 0))
            
            if service_name in service_costs:
                service_costs[service_name] += service_cost
            else:
                service_costs[service_name] = service_cost
    
    # Sort services by cost (descending)
    sorted_services = sorted(service_costs.items(), key=lambda x: x[1], reverse=True)
    
    # Create summary
    summary = {
        'summary': {
            'total_cost': round(total_cost, 2),
            'currency': currency,
            'period': f"{start_date} to {end_date}",
            'service_count': len(service_costs),
            'top_services': [
                {
                    'service': service,
                    'cost': round(cost, 2),
                    'percentage': round((cost / total_cost * 100) if total_cost > 0 else 0, 1)
                }
                for service, cost in sorted_services
            ]
        },
        'detailed_breakdown': {
            'by_service': dict(sorted_services),
            'raw_response_summary': {
                'time_periods': len(results_by_time),
                'total_groups': sum(len(tp.get('Groups', [])) for tp in results_by_time)
            }
        }
    }
    
    return summary
