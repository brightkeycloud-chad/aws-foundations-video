# DynamoDB Table Operations - Terminal & SDK Demonstration

## Overview
This 5-minute demonstration shows how to perform DynamoDB operations using the AWS CLI and SDK. You'll learn to create tables, perform CRUD operations, and manage data programmatically.

## Prerequisites
- AWS CLI installed and configured with appropriate credentials
- Python 3.x installed (for SDK examples)
- boto3 library installed (`pip install boto3`)
- Basic understanding of command line operations

## Quick Start Options

### Option 1: Run Complete Demonstration
Execute all steps automatically with pauses between each step:
```bash
./run_all_steps.sh
```

### Option 2: Run Individual Steps
Execute each step manually for detailed explanation:
```bash
./step1_create_table.sh      # Create DynamoDB table
./step2_add_items.sh         # Add sample items
./step3_query_operations.sh  # Query and get operations
./step4_update_delete.sh     # Update and delete operations
./step5_python_sdk_demo.py   # Python SDK demonstration
./cleanup.sh                 # Clean up resources
```

### Option 3: Manual Commands (Original Method)
Follow the step-by-step commands below for manual execution.

## Demonstration Steps (5 minutes)

### Step 1: Create Table with AWS CLI (1 minute)
```bash
# Create a Music table with partition key (Artist) and sort key (SongTitle)
aws dynamodb create-table \
    --table-name Music \
    --attribute-definitions \
        AttributeName=Artist,AttributeType=S \
        AttributeName=SongTitle,AttributeType=S \
    --key-schema \
        AttributeName=Artist,KeyType=HASH \
        AttributeName=SongTitle,KeyType=RANGE \
    --billing-mode PAY_PER_REQUEST \
    --table-class STANDARD

# Check table status
aws dynamodb describe-table --table-name Music --query 'Table.TableStatus'
```

### Step 2: Add Items Using CLI (1.5 minutes)
```bash
# Add first item
aws dynamodb put-item \
    --table-name Music \
    --item '{
        "Artist": {"S": "The Beatles"},
        "SongTitle": {"S": "Hey Jude"},
        "Album": {"S": "The Beatles 1967-1970"},
        "Year": {"N": "1968"},
        "Genre": {"S": "Rock"}
    }'

# Add second item
aws dynamodb put-item \
    --table-name Music \
    --item '{
        "Artist": {"S": "Queen"},
        "SongTitle": {"S": "Bohemian Rhapsody"},
        "Album": {"S": "A Night at the Opera"},
        "Year": {"N": "1975"},
        "Genre": {"S": "Rock"}
    }'

# Add third item with different attributes (demonstrating schema flexibility)
aws dynamodb put-item \
    --table-name Music \
    --item '{
        "Artist": {"S": "Miles Davis"},
        "SongTitle": {"S": "Kind of Blue"},
        "Album": {"S": "Kind of Blue"},
        "Year": {"N": "1959"},
        "Genre": {"S": "Jazz"},
        "Duration": {"N": "45"}
    }'
```

### Step 3: Query and Get Operations (1.5 minutes)
```bash
# Get specific item
aws dynamodb get-item \
    --table-name Music \
    --key '{
        "Artist": {"S": "The Beatles"},
        "SongTitle": {"S": "Hey Jude"}
    }'

# Query all songs by The Beatles
aws dynamodb query \
    --table-name Music \
    --key-condition-expression "Artist = :artist" \
    --expression-attribute-values '{
        ":artist": {"S": "The Beatles"}
    }'

# Scan table with filter (less efficient, for demonstration)
aws dynamodb scan \
    --table-name Music \
    --filter-expression "Genre = :genre" \
    --expression-attribute-values '{
        ":genre": {"S": "Rock"}
    }'
```

### Step 4: Update and Delete Operations (1 minute)
```bash
# Update item - add rating attribute
aws dynamodb update-item \
    --table-name Music \
    --key '{
        "Artist": {"S": "Queen"},
        "SongTitle": {"S": "Bohemian Rhapsody"}
    }' \
    --update-expression "SET Rating = :rating, LastPlayed = :date" \
    --expression-attribute-values '{
        ":rating": {"N": "5"},
        ":date": {"S": "2024-01-15"}
    }' \
    --return-values ALL_NEW

# Delete an item
aws dynamodb delete-item \
    --table-name Music \
    --key '{
        "Artist": {"S": "Miles Davis"},
        "SongTitle": {"S": "Kind of Blue"}
    }'
```

## Python SDK Example (Bonus - if time permits)

Create a file named `dynamodb_example.py`:

```python
import boto3
from botocore.exceptions import ClientError

# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Music')

def add_song(artist, song_title, album, year, genre):
    """Add a song to the Music table"""
    try:
        response = table.put_item(
            Item={
                'Artist': artist,
                'SongTitle': song_title,
                'Album': album,
                'Year': year,
                'Genre': genre
            }
        )
        print(f"Added song: {song_title} by {artist}")
    except ClientError as e:
        print(f"Error adding song: {e}")

def get_song(artist, song_title):
    """Get a specific song from the table"""
    try:
        response = table.get_item(
            Key={
                'Artist': artist,
                'SongTitle': song_title
            }
        )
        if 'Item' in response:
            return response['Item']
        else:
            print("Song not found")
            return None
    except ClientError as e:
        print(f"Error getting song: {e}")
        return None

# Example usage
if __name__ == "__main__":
    # Add a song
    add_song("Pink Floyd", "Wish You Were Here", "Wish You Were Here", 1975, "Progressive Rock")
    
    # Get the song
    song = get_song("Pink Floyd", "Wish You Were Here")
    if song:
        print(f"Retrieved: {song}")
```

Run the Python example:
```bash
python dynamodb_example.py
```

## Key Learning Points
- AWS CLI provides full DynamoDB functionality through command line
- JSON format is used for complex data structures in CLI
- Query operations require partition key, can optionally use sort key
- Scan operations read entire table (expensive for large tables)
- Update expressions allow atomic updates of specific attributes
- Python SDK (boto3) provides more intuitive programming interface

## Best Practices Demonstrated
- Use PAY_PER_REQUEST billing for unpredictable workloads
- Query is more efficient than Scan for targeted data retrieval
- Use expression attribute values to avoid conflicts with reserved words
- Handle exceptions properly in SDK code
- Use consistent naming conventions for attributes

## Cleanup
```bash
# Delete the table to avoid charges
aws dynamodb delete-table --table-name Music

# Verify deletion
aws dynamodb list-tables
```

## Performance Tips
- Use Query instead of Scan when possible
- Design partition keys to distribute data evenly
- Use projection expressions to retrieve only needed attributes
- Consider using batch operations for multiple items
- Enable point-in-time recovery for production tables

## Additional Resources
- [AWS CLI DynamoDB Reference](https://docs.aws.amazon.com/cli/latest/reference/dynamodb/)
- [Boto3 DynamoDB Documentation](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/dynamodb.html)
- [DynamoDB Best Practices](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/best-practices.html)

## Citations
1. AWS Documentation - Getting started with DynamoDB: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/GettingStartedDynamoDB.html
2. AWS Documentation - Create a table in DynamoDB: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/getting-started-step-1.html
3. AWS Documentation - Working with items and attributes: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/WorkingWithItems.html
4. AWS CLI DynamoDB Reference: https://docs.aws.amazon.com/cli/latest/reference/dynamodb/
5. Boto3 DynamoDB Documentation: https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/dynamodb.html
