#!/bin/bash

# Step 1: Create Table with AWS CLI
# DynamoDB Table Operations Demo

set -e  # Exit on any error

echo "🎵 Step 1: Creating DynamoDB Table"
echo "=================================="
echo

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Creating Music table with partition key (Artist) and sort key (SongTitle)...${NC}"
echo

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

echo -e "${GREEN}✓ Table creation initiated${NC}"
echo

echo -e "${YELLOW}Waiting for table to become active...${NC}"
# Check table status
echo "Current table status:"
aws dynamodb describe-table --table-name Music --query 'Table.TableStatus' --output text

echo
echo "Waiting for table to be ready..."
aws dynamodb wait table-exists --table-name Music

echo -e "${GREEN}✓ Table 'Music' is now ACTIVE and ready for use!${NC}"
echo

# Show table details
echo "Table details:"
aws dynamodb describe-table --table-name Music --query 'Table.{Name:TableName,Status:TableStatus,Keys:KeySchema,Billing:BillingModeSummary.BillingMode}' --output table

echo
echo -e "${BLUE}Step 1 completed successfully!${NC}"
echo "You can now proceed to Step 2 to add items to the table."
