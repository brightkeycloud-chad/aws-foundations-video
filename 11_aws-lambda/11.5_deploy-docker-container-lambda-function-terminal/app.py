import json
import boto3
import requests
from datetime import datetime, timezone
import logging
import os
import random

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def lambda_handler(event, context):
    """
    Lambda function deployed as container image.
    Processes data and generates analytics using built-in Python libraries.
    Includes local testing support.
    """
    
    logger.info(f"Container function started at {datetime.now(timezone.utc).isoformat()}")
    logger.info(f"Python version: {os.sys.version}")
    logger.info(f"Received event: {json.dumps(event)}")
    
    # Check if running in local test mode
    is_local_test = os.environ.get('AWS_ACCESS_KEY_ID') == 'test'
    
    try:
        # Extract parameters
        data_type = event.get('data_type', 'sales')
        output_bucket = event.get('output_bucket')
        record_count = event.get('record_count', 100)
        
        if not output_bucket:
            raise ValueError("output_bucket is required in the event")
        
        # Generate sample data based on type
        if data_type == 'sales':
            data = generate_sales_data(record_count)
        elif data_type == 'inventory':
            data = generate_inventory_data()
        elif data_type == 'api_test':
            data = test_external_api()
        else:
            raise ValueError(f"Unsupported data_type: {data_type}")
        
        logger.info(f"Generated {len(data)} records of type {data_type}")
        
        # Perform analytics using built-in Python functions
        analytics = perform_analytics(data, data_type)
        
        # Handle S3 operations (mock for local testing)
        if is_local_test:
            logger.info("Local test mode: Skipping S3 operations")
            timestamp = datetime.now(timezone.utc).strftime('%Y%m%d-%H%M%S')
            s3_results = {
                'raw_data': f"s3://{output_bucket}/analytics/{data_type}/raw-data-{timestamp}.json",
                'analytics': f"s3://{output_bucket}/analytics/{data_type}/results-{timestamp}.json"
            }
        else:
            # Save results to S3 (real AWS environment)
            s3_results = save_to_s3(data, analytics, data_type, output_bucket)
        
        # Create context mock for local testing
        if not hasattr(context, 'function_name'):
            context = type('MockContext', (), {
                'function_name': 'local-test-function',
                'aws_request_id': 'local-test-request-id',
                'memory_limit_in_mb': 512
            })()
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Analytics processing completed successfully',
                'data_type': data_type,
                'records_processed': len(data),
                'output_files': s3_results,
                'analytics_summary': {
                    'total_records': analytics['summary']['total_records'],
                    'key_metrics': analytics['key_metrics']
                },
                'container_info': {
                    'function_name': context.function_name,
                    'request_id': context.aws_request_id,
                    'memory_limit': context.memory_limit_in_mb,
                    'python_version': os.sys.version.split()[0],
                    'local_test_mode': is_local_test
                }
            })
        }
        
    except Exception as e:
        logger.error(f"Function execution failed: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': 'Processing failed',
                'details': str(e),
                'local_test_mode': is_local_test
            })
        }

def save_to_s3(data, analytics, data_type, output_bucket):
    """Save results to S3 (only in real AWS environment)"""
    s3_client = boto3.client('s3')
    timestamp = datetime.now(timezone.utc).strftime('%Y%m%d-%H%M%S')
    
    # Save raw data as JSON
    json_key = f"analytics/{data_type}/raw-data-{timestamp}.json"
    s3_client.put_object(
        Bucket=output_bucket,
        Key=json_key,
        Body=json.dumps(data, indent=2, default=str),
        ContentType='application/json'
    )
    
    # Save analytics results
    analytics_key = f"analytics/{data_type}/results-{timestamp}.json"
    s3_client.put_object(
        Bucket=output_bucket,
        Key=analytics_key,
        Body=json.dumps(analytics, indent=2, default=str),
        ContentType='application/json'
    )
    
    logger.info(f"Results saved to S3: {output_bucket}")
    
    return {
        'raw_data': f"s3://{output_bucket}/{json_key}",
        'analytics': f"s3://{output_bucket}/{analytics_key}"
    }

def generate_sales_data(count=100):
    """Generate sample sales data using built-in random module"""
    random.seed(42)  # For reproducible results
    
    products = ['Widget A', 'Widget B', 'Widget C', 'Widget D', 'Widget E']
    regions = ['North', 'South', 'East', 'West']
    
    data = []
    for i in range(count):
        quantity = random.randint(1, 20)
        unit_price = round(random.uniform(10, 100), 2)
        data.append({
            'transaction_id': f"TXN-{i+1:04d}",
            'product': random.choice(products),
            'region': random.choice(regions),
            'quantity': quantity,
            'unit_price': unit_price,
            'total_amount': round(quantity * unit_price, 2),
            'date': (datetime.now(timezone.utc).replace(
                day=random.randint(1, 28)
            )).strftime('%Y-%m-%d')
        })
    
    return data

def generate_inventory_data():
    """Generate sample inventory data"""
    random.seed(42)
    
    products = ['Widget A', 'Widget B', 'Widget C', 'Widget D', 'Widget E']
    warehouses = ['WH-001', 'WH-002', 'WH-003']
    
    data = []
    for product in products:
        for warehouse in warehouses:
            current_stock = random.randint(0, 500)
            reorder_level = random.randint(50, 100)
            data.append({
                'product': product,
                'warehouse': warehouse,
                'current_stock': current_stock,
                'reorder_level': reorder_level,
                'max_capacity': random.randint(800, 1200),
                'needs_reorder': current_stock <= reorder_level,
                'last_updated': datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S')
            })
    
    return data

def test_external_api():
    """Test external API integration"""
    try:
        response = requests.get('https://httpbin.org/json', timeout=10)
        response.raise_for_status()
        api_data = response.json()
        
        return [{
            'api_test': True,
            'status': 'success',
            'response_data': api_data,
            'timestamp': datetime.now(timezone.utc).isoformat()
        }]
    except Exception as e:
        return [{
            'api_test': True,
            'status': 'failed',
            'error': str(e),
            'timestamp': datetime.now(timezone.utc).isoformat()
        }]

def perform_analytics(data, data_type):
    """Perform analytics using built-in Python functions"""
    
    if data_type == 'sales':
        # Calculate totals and averages
        total_revenue = sum(item['total_amount'] for item in data)
        total_quantity = sum(item['quantity'] for item in data)
        avg_order_value = total_revenue / len(data) if data else 0
        
        # Group by product
        product_stats = {}
        for item in data:
            product = item['product']
            if product not in product_stats:
                product_stats[product] = {'revenue': 0, 'quantity': 0, 'orders': 0}
            product_stats[product]['revenue'] += item['total_amount']
            product_stats[product]['quantity'] += item['quantity']
            product_stats[product]['orders'] += 1
        
        # Group by region
        region_stats = {}
        for item in data:
            region = item['region']
            if region not in region_stats:
                region_stats[region] = {'revenue': 0, 'quantity': 0, 'orders': 0}
            region_stats[region]['revenue'] += item['total_amount']
            region_stats[region]['quantity'] += item['quantity']
            region_stats[region]['orders'] += 1
        
        return {
            'summary': {
                'total_records': len(data),
                'data_type': data_type
            },
            'key_metrics': {
                'total_revenue': round(total_revenue, 2),
                'average_order_value': round(avg_order_value, 2),
                'total_quantity_sold': total_quantity
            },
            'by_product': product_stats,
            'by_region': region_stats
        }
    
    elif data_type == 'inventory':
        total_stock = sum(item['current_stock'] for item in data)
        total_capacity = sum(item['max_capacity'] for item in data)
        items_needing_reorder = sum(1 for item in data if item['needs_reorder'])
        
        # Group by warehouse
        warehouse_stats = {}
        for item in data:
            warehouse = item['warehouse']
            if warehouse not in warehouse_stats:
                warehouse_stats[warehouse] = {'stock': 0, 'capacity': 0, 'products': 0}
            warehouse_stats[warehouse]['stock'] += item['current_stock']
            warehouse_stats[warehouse]['capacity'] += item['max_capacity']
            warehouse_stats[warehouse]['products'] += 1
        
        return {
            'summary': {
                'total_records': len(data),
                'data_type': data_type
            },
            'key_metrics': {
                'total_current_stock': total_stock,
                'total_capacity': total_capacity,
                'capacity_utilization': round((total_stock / total_capacity * 100) if total_capacity > 0 else 0, 1),
                'items_needing_reorder': items_needing_reorder
            },
            'by_warehouse': warehouse_stats,
            'alerts': {
                'low_stock_items': [item['product'] for item in data if item['needs_reorder']]
            }
        }
    
    elif data_type == 'api_test':
        successful_calls = sum(1 for item in data if item.get('status') == 'success')
        failed_calls = len(data) - successful_calls
        
        return {
            'summary': {
                'total_records': len(data),
                'data_type': data_type
            },
            'key_metrics': {
                'successful_api_calls': successful_calls,
                'failed_api_calls': failed_calls,
                'success_rate': round((successful_calls / len(data) * 100) if data else 0, 1)
            },
            'test_results': data
        }
    
    return {'summary': {'total_records': len(data)}, 'key_metrics': {}}
