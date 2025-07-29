#!/bin/bash

# Cleanup Script - Delete DynamoDB Table
# DynamoDB Table Operations Demo

set -e  # Exit on any error

echo "🧹 Cleanup: Deleting DynamoDB Resources"
echo "======================================="
echo

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if table exists
echo -e "${BLUE}Checking if Music table exists...${NC}"
if ! aws dynamodb describe-table --table-name Music --query 'Table.TableStatus' --output text > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Music table not found. Nothing to clean up.${NC}"
    exit 0
fi

echo -e "${GREEN}✓ Music table found${NC}"
echo

# Show current table contents before deletion
echo -e "${BLUE}Current table contents (before deletion):${NC}"
ITEM_COUNT=$(aws dynamodb scan --table-name Music --select COUNT --query 'Count' --output text)
echo "Total items in table: $ITEM_COUNT"

if [ "$ITEM_COUNT" -gt 0 ]; then
    echo
    echo "Items that will be deleted:"
    aws dynamodb scan --table-name Music --query 'Items[].{Artist:Artist.S,Song:SongTitle.S,Album:Album.S,Year:Year.N,Genre:Genre.S}' --output table
fi

echo
echo -e "${YELLOW}⚠️  WARNING: This will permanently delete the Music table and all its data!${NC}"
echo -e "${YELLOW}This action cannot be undone.${NC}"
echo

# Prompt for confirmation
read -p "Are you sure you want to delete the Music table? (yes/no): " -r
echo

if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo -e "${BLUE}Cleanup cancelled. Table preserved.${NC}"
    exit 0
fi

echo -e "${BLUE}Deleting Music table...${NC}"

# Delete the table
aws dynamodb delete-table --table-name Music > /dev/null

echo -e "${GREEN}✓ Table deletion initiated${NC}"
echo

echo -e "${YELLOW}Waiting for table to be fully deleted...${NC}"
echo "This may take a few moments..."

# Wait for table to be deleted
aws dynamodb wait table-not-exists --table-name Music

echo -e "${GREEN}✓ Music table has been completely deleted${NC}"
echo

# Verify deletion
echo -e "${BLUE}Verifying deletion...${NC}"
if aws dynamodb describe-table --table-name Music > /dev/null 2>&1; then
    echo -e "${RED}✗ Table still exists (unexpected)${NC}"
    exit 1
else
    echo -e "${GREEN}✓ Confirmed: Music table no longer exists${NC}"
fi

echo
echo -e "${GREEN}Cleanup completed successfully! 🎉${NC}"
echo
echo "Summary:"
echo "  ✓ Music table deleted"
echo "  ✓ All table data removed"
echo "  ✓ No ongoing charges for this table"
echo
echo "The demonstration environment has been cleaned up."
echo "You can run the demonstration again by starting with step1_create_table.sh"
