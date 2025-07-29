# DynamoDB Demonstrations - Quick Reference Guide

## Overview
This directory contains two 5-minute demonstrations for Amazon DynamoDB:

1. **16.3_deploy-dynamodb-table-console** - Console-based demonstration
2. **16.4_dynamodb-table-operations-terminal-sdk** - CLI and SDK demonstration

## Demonstration Summaries

### Console Demonstration (16.3)
**Duration**: 5 minutes  
**Focus**: Creating and managing DynamoDB tables through AWS Management Console

**Key Activities**:
- Create ProductCatalog table with partition and sort keys
- Add sample items with different attributes
- Perform query and scan operations
- Demonstrate schema-less design

**Learning Outcomes**:
- Understanding DynamoDB table structure
- Console navigation and basic operations
- NoSQL flexibility with varying item attributes

### Terminal/SDK Demonstration (16.4)
**Duration**: 5 minutes  
**Focus**: Programmatic DynamoDB operations using AWS CLI and Python SDK

**Key Activities**:
- Create Music table using AWS CLI
- Perform CRUD operations via command line
- Demonstrate Python SDK usage with boto3
- Show query vs scan performance differences

**Learning Outcomes**:
- CLI proficiency for DynamoDB operations
- SDK programming patterns
- Best practices for programmatic access

## Prerequisites for Both Demonstrations
- AWS account with DynamoDB permissions
- AWS CLI configured (for terminal demo)
- Python 3.x and boto3 (for SDK examples)

## Key DynamoDB Concepts Covered
- **Partition Key**: Primary identifier for data distribution
- **Sort Key**: Optional secondary key for item ordering
- **Schema-less Design**: Items can have different attributes
- **Query vs Scan**: Efficient vs inefficient data retrieval
- **CRUD Operations**: Create, Read, Update, Delete
- **Billing Modes**: Pay-per-request vs provisioned capacity

## Common Commands Reference

### AWS CLI Commands
```bash
# Create table
aws dynamodb create-table --table-name <name> --attribute-definitions ... --key-schema ...

# Add item
aws dynamodb put-item --table-name <name> --item '<json>'

# Get item
aws dynamodb get-item --table-name <name> --key '<json>'

# Query items
aws dynamodb query --table-name <name> --key-condition-expression "..."

# Update item
aws dynamodb update-item --table-name <name> --key '<json>' --update-expression "..."

# Delete item
aws dynamodb delete-item --table-name <name> --key '<json>'

# Delete table
aws dynamodb delete-table --table-name <name>
```

### Python SDK Patterns
```python
import boto3

# Initialize
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('TableName')

# Basic operations
table.put_item(Item={...})
table.get_item(Key={...})
table.update_item(Key={...}, UpdateExpression="...")
table.delete_item(Key={...})
table.query(KeyConditionExpression=...)
table.scan(FilterExpression=...)
```

## Best Practices Highlighted
1. **Design for Access Patterns**: Structure keys based on how you'll query data
2. **Use Query Over Scan**: More efficient for targeted data retrieval
3. **Distribute Data Evenly**: Choose partition keys that spread data across partitions
4. **Handle Exceptions**: Always implement proper error handling
5. **Use Appropriate Billing Mode**: Pay-per-request for unpredictable workloads

## Troubleshooting Tips
- Ensure AWS credentials are properly configured
- Check table status before performing operations
- Verify JSON syntax in CLI commands
- Use `--dry-run` flag to test commands without execution
- Monitor AWS CloudWatch for performance metrics

## Cost Considerations
- Both demonstrations use pay-per-request billing to minimize costs
- Remember to delete tables after demonstrations to avoid ongoing charges
- Free tier includes 25 GB of storage and 25 WCU/RCU

## Additional Learning Resources
- [DynamoDB Developer Guide](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/)
- [AWS CLI DynamoDB Reference](https://docs.aws.amazon.com/cli/latest/reference/dynamodb/)
- [Boto3 DynamoDB Documentation](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/dynamodb.html)
- [DynamoDB Best Practices](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/best-practices.html)

## Support
For questions about these demonstrations, refer to the individual README files in each subdirectory or consult the AWS documentation links provided.
