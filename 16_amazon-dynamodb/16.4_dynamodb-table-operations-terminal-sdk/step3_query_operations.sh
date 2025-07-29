#!/bin/bash

# Step 3: Query and Get Operations
# DynamoDB Table Operations Demo

set -e  # Exit on any error

echo "🎵 Step 3: Query and Get Operations"
echo "==================================="
echo

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if table exists and has data
echo -e "${BLUE}Checking Music table status...${NC}"
if ! aws dynamodb describe-table --table-name Music --query 'Table.TableStatus' --output text > /dev/null 2>&1; then
    echo -e "${RED}✗ Music table not found. Please run step1_create_table.sh first.${NC}"
    exit 1
fi

# Check if table has items
ITEM_COUNT=$(aws dynamodb scan --table-name Music --select COUNT --query 'Count' --output text)
if [ "$ITEM_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Music table is empty. Please run step2_add_items.sh first.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Music table found with $ITEM_COUNT items${NC}"
echo

# Operation 1: Get specific item
echo -e "${BLUE}1. Getting specific item (Hey Jude by The Beatles)...${NC}"
echo "Command: aws dynamodb get-item --table-name Music --key '{\"Artist\":{\"S\":\"The Beatles\"},\"SongTitle\":{\"S\":\"Hey Jude\"}}'"
echo

aws dynamodb get-item \
    --table-name Music \
    --key '{
        "Artist": {"S": "The Beatles"},
        "SongTitle": {"S": "Hey Jude"}
    }' \
    --output table

echo -e "${GREEN}✓ Retrieved specific item successfully${NC}"
echo
echo "---"
echo

# Operation 2: Query all songs by The Beatles
echo -e "${BLUE}2. Querying all songs by The Beatles...${NC}"
echo "Command: aws dynamodb query --table-name Music --key-condition-expression \"Artist = :artist\""
echo

aws dynamodb query \
    --table-name Music \
    --key-condition-expression "Artist = :artist" \
    --expression-attribute-values '{
        ":artist": {"S": "The Beatles"}
    }' \
    --output table

echo -e "${GREEN}✓ Query operation completed${NC}"
echo
echo "---"
echo

# Operation 3: Query with projection (only specific attributes)
echo -e "${BLUE}3. Querying with projection (only Song and Album)...${NC}"
echo "Command: aws dynamodb query with --projection-expression"
echo

aws dynamodb query \
    --table-name Music \
    --key-condition-expression "Artist = :artist" \
    --expression-attribute-values '{
        ":artist": {"S": "The Beatles"}
    }' \
    --projection-expression "SongTitle, Album" \
    --output table

echo -e "${GREEN}✓ Projection query completed${NC}"
echo
echo "---"
echo

# Operation 4: Scan table with filter (less efficient, for demonstration)
echo -e "${BLUE}4. Scanning for Rock songs (less efficient than query)...${NC}"
echo "Command: aws dynamodb scan --table-name Music --filter-expression \"Genre = :genre\""
echo -e "${YELLOW}Note: Scan operations read the entire table and then filter - less efficient than Query${NC}"
echo

aws dynamodb scan \
    --table-name Music \
    --filter-expression "Genre = :genre" \
    --expression-attribute-values '{
        ":genre": {"S": "Rock"}
    }' \
    --output table

echo -e "${GREEN}✓ Scan operation completed${NC}"
echo
echo "---"
echo

# Operation 5: Get item that doesn't exist (error handling demo)
echo -e "${BLUE}5. Attempting to get non-existent item (error handling demo)...${NC}"
echo "Command: aws dynamodb get-item for non-existent song"
echo

RESULT=$(aws dynamodb get-item \
    --table-name Music \
    --key '{
        "Artist": {"S": "Non-existent Artist"},
        "SongTitle": {"S": "Non-existent Song"}
    }' \
    --output json)

if echo "$RESULT" | grep -q '"Item"'; then
    echo "Item found (unexpected)"
else
    echo -e "${YELLOW}No item found (as expected) - empty result returned${NC}"
fi

echo
echo -e "${GREEN}Step 3 completed successfully!${NC}"
echo
echo "Operations demonstrated:"
echo "  ✓ GetItem - Retrieve specific item by full primary key"
echo "  ✓ Query - Efficient retrieval by partition key"
echo "  ✓ Query with Projection - Retrieve only specific attributes"
echo "  ✓ Scan with Filter - Less efficient full-table scan"
echo "  ✓ Error Handling - Graceful handling of non-existent items"
echo
echo "Key Takeaways:"
echo "  • Query operations are more efficient than Scan"
echo "  • GetItem requires the complete primary key"
echo "  • Projection expressions reduce data transfer"
echo "  • Scan operations consume more capacity units"
echo
echo "You can now proceed to Step 4 to update and delete items."
