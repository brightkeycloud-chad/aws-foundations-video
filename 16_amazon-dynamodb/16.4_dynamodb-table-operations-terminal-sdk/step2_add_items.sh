#!/bin/bash

# Step 2: Add Items Using CLI
# DynamoDB Table Operations Demo

set -e  # Exit on any error

echo "🎵 Step 2: Adding Items to Music Table"
echo "======================================"
echo

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if table exists first
echo -e "${BLUE}Checking if Music table exists...${NC}"
if ! aws dynamodb describe-table --table-name Music --query 'Table.TableStatus' --output text > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Music table not found. Please run step1_create_table.sh first.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Music table found${NC}"
echo

echo -e "${BLUE}Adding sample music items...${NC}"
echo

# Add first item - The Beatles
echo "Adding: Hey Jude by The Beatles..."
aws dynamodb put-item \
    --table-name Music \
    --item '{
        "Artist": {"S": "The Beatles"},
        "SongTitle": {"S": "Hey Jude"},
        "Album": {"S": "The Beatles 1967-1970"},
        "Year": {"N": "1968"},
        "Genre": {"S": "Rock"}
    }'

echo -e "${GREEN}✓ Added: Hey Jude by The Beatles${NC}"
echo

# Add second item - Queen
echo "Adding: Bohemian Rhapsody by Queen..."
aws dynamodb put-item \
    --table-name Music \
    --item '{
        "Artist": {"S": "Queen"},
        "SongTitle": {"S": "Bohemian Rhapsody"},
        "Album": {"S": "A Night at the Opera"},
        "Year": {"N": "1975"},
        "Genre": {"S": "Rock"}
    }'

echo -e "${GREEN}✓ Added: Bohemian Rhapsody by Queen${NC}"
echo

# Add third item - Miles Davis (with different attributes to show schema flexibility)
echo "Adding: Kind of Blue by Miles Davis (with additional Duration attribute)..."
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

echo -e "${GREEN}✓ Added: Kind of Blue by Miles Davis${NC}"
echo

# Verify items were added by scanning the table
echo -e "${BLUE}Verifying items were added successfully...${NC}"
echo
echo "Current items in Music table:"
aws dynamodb scan --table-name Music --query 'Items[].{Artist:Artist.S,Song:SongTitle.S,Album:Album.S,Year:Year.N,Genre:Genre.S}' --output table

echo
echo -e "${GREEN}Step 2 completed successfully!${NC}"
echo "Added 3 songs demonstrating schema flexibility:"
echo "  • The Beatles - Hey Jude (Rock, 1968)"
echo "  • Queen - Bohemian Rhapsody (Rock, 1975)"
echo "  • Miles Davis - Kind of Blue (Jazz, 1959) [with Duration attribute]"
echo
echo "You can now proceed to Step 3 to query and retrieve items."
