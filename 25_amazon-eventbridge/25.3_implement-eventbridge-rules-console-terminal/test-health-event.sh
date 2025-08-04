#!/bin/bash

# AWS Health Event Test Script
# This script tests the Lambda function with sample AWS Health events

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

FUNCTION_NAME="HealthEventProcessor"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to create sample AWS Health events
create_sample_events() {
    # Sample 1: EC2 Operational Issue (Public Event)
    cat > sample-ec2-issue.json << 'EOF'
{
    "version": "0",
    "id": "7bf73129-1428-4cd3-a780-95db273d1602",
    "detail-type": "AWS Health Event",
    "source": "aws.health",
    "account": "123456789012",
    "time": "2024-01-27T09:01:22Z",
    "region": "us-east-1",
    "resources": [],
    "detail": {
        "eventArn": "arn:aws:health:us-east-1::event/EC2/AWS_EC2_OPERATIONAL_ISSUE/AWS_EC2_OPERATIONAL_ISSUE_7f35c8ae-af1f-54e6-a526-d0179ed6d68f",
        "service": "EC2",
        "eventTypeCode": "AWS_EC2_OPERATIONAL_ISSUE",
        "eventTypeCategory": "issue",
        "eventScopeCode": "PUBLIC",
        "communicationId": "01b0993207d81a09dcd552ebd1e633e36cf1f09a-1",
        "startTime": "Fri, 27 Jan 2024 06:02:51 GMT",
        "endTime": "Fri, 27 Jan 2024 09:01:22 GMT",
        "lastUpdatedTime": "Fri, 27 Jan 2024 09:01:22 GMT",
        "statusCode": "open",
        "eventRegion": "us-east-1",
        "eventDescription": [{
            "language": "en_US",
            "latestDescription": "We are investigating connectivity issues affecting some EC2 instances in the US-East-1 region. Customers may experience intermittent connectivity issues with their instances. We are working to resolve this issue as quickly as possible and will provide updates as they become available."
        }],
        "affectedEntities": [],
        "page": "1",
        "totalPages": "1",
        "affectedAccount": "123456789012"
    }
}
EOF

    # Sample 2: RDS Maintenance Scheduled (Account-specific)
    cat > sample-rds-maintenance.json << 'EOF'
{
    "version": "0",
    "id": "121345678-1234-1234-1234-123456789012",
    "detail-type": "AWS Health Event",
    "source": "aws.health",
    "account": "123456789012",
    "time": "2024-02-15T10:30:00Z",
    "region": "us-west-2",
    "resources": [
        "mydb-instance-1"
    ],
    "detail": {
        "eventArn": "arn:aws:health:us-west-2::event/RDS/AWS_RDS_MAINTENANCE_SCHEDULED/AWS_RDS_MAINTENANCE_SCHEDULED_90353408594353980",
        "service": "RDS",
        "eventTypeCode": "AWS_RDS_MAINTENANCE_SCHEDULED",
        "eventTypeCategory": "scheduledChange",
        "eventScopeCode": "ACCOUNT_SPECIFIC",
        "communicationId": "02c1004318e92b10ede663fce2f744e47dg2g10b-1",
        "startTime": "Sat, 24 Feb 2024 02:00:00 GMT",
        "endTime": "Sat, 24 Feb 2024 06:00:00 GMT",
        "lastUpdatedTime": "Thu, 15 Feb 2024 10:30:00 GMT",
        "statusCode": "upcoming",
        "eventRegion": "us-west-2",
        "eventDescription": [{
            "language": "en_US",
            "latestDescription": "Scheduled maintenance is planned for your RDS instance mydb-instance-1. During this maintenance window, your database may experience brief periods of unavailability. The maintenance will include security updates and performance improvements. No action is required from you."
        }],
        "affectedEntities": [{
            "entityValue": "mydb-instance-1",
            "lastUpdatedTime": "Thu, 15 Feb 2024 10:30:00 GMT",
            "status": "PENDING"
        }],
        "page": "1",
        "totalPages": "1",
        "affectedAccount": "123456789012"
    }
}
EOF

    # Sample 3: S3 Service Degradation (Resolved)
    cat > sample-s3-resolved.json << 'EOF'
{
    "version": "0",
    "id": "331456789-5678-9012-3456-789012345678",
    "detail-type": "AWS Health Event",
    "source": "aws.health",
    "account": "123456789012",
    "time": "2024-01-20T14:45:30Z",
    "region": "eu-west-1",
    "resources": [],
    "detail": {
        "eventArn": "arn:aws:health:eu-west-1::event/S3/AWS_S3_OPERATIONAL_ISSUE/AWS_S3_OPERATIONAL_ISSUE_8g46d9bf-bg2g-65h7-b637-e1290fe7e79g",
        "service": "S3",
        "eventTypeCode": "AWS_S3_OPERATIONAL_ISSUE",
        "eventTypeCategory": "issue",
        "eventScopeCode": "PUBLIC",
        "communicationId": "03d2115429f03c21fef774gdf3g855f58eh3h21c-1",
        "startTime": "Sat, 20 Jan 2024 12:15:00 GMT",
        "endTime": "Sat, 20 Jan 2024 14:45:30 GMT",
        "lastUpdatedTime": "Sat, 20 Jan 2024 14:45:30 GMT",
        "statusCode": "closed",
        "eventRegion": "eu-west-1",
        "eventDescription": [{
            "language": "en_US",
            "latestDescription": "[RESOLVED] We have resolved the issue that was causing elevated error rates for S3 API requests in the EU-West-1 region. All S3 operations are now functioning normally. We apologize for any inconvenience this may have caused."
        }],
        "affectedEntities": [],
        "page": "1",
        "totalPages": "1",
        "affectedAccount": "123456789012"
    }
}
EOF

    # Sample 4: Lambda Investigation
    cat > sample-lambda-investigation.json << 'EOF'
{
    "version": "0",
    "id": "441567890-6789-0123-4567-890123456789",
    "detail-type": "AWS Health Event",
    "source": "aws.health",
    "account": "123456789012",
    "time": "2024-02-10T08:20:15Z",
    "region": "ap-southeast-2",
    "resources": [],
    "detail": {
        "eventArn": "arn:aws:health:ap-southeast-2::event/LAMBDA/AWS_LAMBDA_OPERATIONAL_ISSUE/AWS_LAMBDA_OPERATIONAL_ISSUE_9h57e0cg-ch3h-76i8-c748-f2301gf8f80h",
        "service": "LAMBDA",
        "eventTypeCode": "AWS_LAMBDA_OPERATIONAL_ISSUE",
        "eventTypeCategory": "investigation",
        "eventScopeCode": "PUBLIC",
        "communicationId": "04e3226530g14d32gfg885heg4h966g69fi4i32d-1",
        "startTime": "Sat, 10 Feb 2024 07:45:00 GMT",
        "lastUpdatedTime": "Sat, 10 Feb 2024 08:20:15 GMT",
        "statusCode": "open",
        "eventRegion": "ap-southeast-2",
        "eventDescription": [{
            "language": "en_US",
            "latestDescription": "We are investigating reports of increased latency for AWS Lambda function invocations in the AP-Southeast-2 region. Some customers may experience slower than normal response times. We are actively working to identify and resolve the root cause."
        }],
        "affectedEntities": [],
        "page": "1",
        "totalPages": "1",
        "affectedAccount": "123456789012"
    }
}
EOF
}

# Function to test Lambda function with sample events
test_lambda_function() {
    local event_file=$1
    local event_name=$2
    
    print_status "Testing with $event_name..."
    
    # Invoke Lambda function
    aws lambda invoke \
        --function-name "$FUNCTION_NAME" \
        --payload file://"$event_file" \
        --cli-binary-format raw-in-base64-out \
        response.json > /dev/null
    
    # Check response
    if [ -f response.json ]; then
        local status_code=$(cat response.json | jq -r '.statusCode // "unknown"')
        if [ "$status_code" = "200" ]; then
            print_success "$event_name test completed successfully"
            
            # Show summary from response
            local summary=$(cat response.json | jq -r '.body' | jq -r '.summary // "No summary available"')
            echo
            echo "Generated Summary:"
            echo "=================="
            echo "$summary"
            echo
        else
            print_error "$event_name test failed with status: $status_code"
            cat response.json
        fi
        rm -f response.json
    else
        print_error "No response received for $event_name"
    fi
}

# Function to show CloudWatch logs
show_logs() {
    print_status "Recent CloudWatch logs for $FUNCTION_NAME:"
    echo
    
    # Get the latest log stream
    LOG_GROUP="/aws/lambda/$FUNCTION_NAME"
    
    # Check if log group exists
    if aws logs describe-log-groups --log-group-name-prefix "$LOG_GROUP" --query 'logGroups[0].logGroupName' --output text 2>/dev/null | grep -q "$LOG_GROUP"; then
        # Get latest log stream
        LATEST_STREAM=$(aws logs describe-log-streams \
            --log-group-name "$LOG_GROUP" \
            --order-by LastEventTime \
            --descending \
            --max-items 1 \
            --query 'logStreams[0].logStreamName' \
            --output text 2>/dev/null)
        
        if [ "$LATEST_STREAM" != "None" ] && [ -n "$LATEST_STREAM" ]; then
            print_status "Latest log stream: $LATEST_STREAM"
            echo
            
            # Get recent log events
            aws logs get-log-events \
                --log-group-name "$LOG_GROUP" \
                --log-stream-name "$LATEST_STREAM" \
                --start-time $(date -d '5 minutes ago' +%s)000 \
                --query 'events[*].message' \
                --output text 2>/dev/null || print_warning "No recent log events found"
        else
            print_warning "No log streams found"
        fi
    else
        print_warning "Log group $LOG_GROUP not found. Function may not have been invoked yet."
    fi
}

# Function to clean up test files
cleanup_test_files() {
    rm -f sample-*.json response.json
}

# Main execution
main() {
    echo "🧪 AWS Health Event Test Suite"
    echo "=============================="
    echo
    
    # Check if Lambda function exists
    if ! aws lambda get-function --function-name "$FUNCTION_NAME" > /dev/null 2>&1; then
        print_error "Lambda function '$FUNCTION_NAME' not found!"
        print_status "Please run './provision-health-monitor.sh' first to create the resources."
        exit 1
    fi
    
    print_status "Creating sample AWS Health events..."
    create_sample_events
    
    echo
    print_status "Testing Lambda function with different event types..."
    echo
    
    # Test each sample event
    test_lambda_function "sample-ec2-issue.json" "EC2 Operational Issue"
    sleep 2
    
    test_lambda_function "sample-rds-maintenance.json" "RDS Scheduled Maintenance"
    sleep 2
    
    test_lambda_function "sample-s3-resolved.json" "S3 Issue (Resolved)"
    sleep 2
    
    test_lambda_function "sample-lambda-investigation.json" "Lambda Investigation"
    
    echo
    print_status "Waiting for logs to propagate..."
    sleep 5
    
    show_logs
    
    cleanup_test_files
    
    echo
    print_success "=== Test Suite Complete ==="
    print_status "Check your email for SNS notifications!"
    print_warning "Note: It may take a few minutes for emails to arrive."
}

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    print_error "jq is required but not installed. Please install jq first."
    print_status "On macOS: brew install jq"
    print_status "On Ubuntu/Debian: sudo apt-get install jq"
    print_status "On Amazon Linux: sudo yum install jq"
    exit 1
fi

# Run main function
main "$@"
