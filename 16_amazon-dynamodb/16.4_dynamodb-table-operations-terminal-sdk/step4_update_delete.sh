#!/bin/bash

# Step 4: Update and Delete Operations
# DynamoDB Table Operations Demo

set -e  # Exit on any error

echo "🎵 Step 4: Update and Delete Operations"
echo "======================================="
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

# Operation 1: Update item - add rating attribute
echo -e "${BLUE}1. Updating item - Adding rating to Bohemian Rhapsody...${NC}"
echo "Command: aws dynamodb update-item with SET expression"
echo "Adding Rating=5 and LastPlayed=2024-01-15 to Queen's Bohemian Rhapsody"
echo

# Show item before update
echo "Item before update:"
aws dynamodb get-item \
    --table-name Music \
    --key '{
        "Artist": {"S": "Queen"},
        "SongTitle": {"S": "Bohemian Rhapsody"}
    }' \
    --query 'Item.{Artist:Artist.S,Song:SongTitle.S,Album:Album.S,Year:Year.N,Genre:Genre.S}' \
    --output table

echo
echo "Performing update..."

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
    --return-values ALL_NEW \
    --output table

echo -e "${GREEN}✓ Update operation completed${NC}"
echo
echo "---"
echo

# Operation 2: Update item - increment a counter
echo -e "${BLUE}2. Adding and incrementing a play count...${NC}"
echo "Command: aws dynamodb update-item with ADD expression"
echo "Adding PlayCount=1 to Hey Jude (atomic counter operation)"
echo

aws dynamodb update-item \
    --table-name Music \
    --key '{
        "Artist": {"S": "The Beatles"},
        "SongTitle": {"S": "Hey Jude"}
    }' \
    --update-expression "ADD PlayCount :increment" \
    --expression-attribute-values '{
        ":increment": {"N": "1"}
    }' \
    --return-values ALL_NEW \
    --output table

echo -e "${GREEN}✓ Counter increment completed${NC}"
echo

# Increment again to show atomic counter behavior
echo "Incrementing play count again to demonstrate atomic counter..."
aws dynamodb update-item \
    --table-name Music \
    --key '{
        "Artist": {"S": "The Beatles"},
        "SongTitle": {"S": "Hey Jude"}
    }' \
    --update-expression "ADD PlayCount :increment" \
    --expression-attribute-values '{
        ":increment": {"N": "1"}
    }' \
    --return-values UPDATED_NEW \
    --query 'Attributes.PlayCount.N' \
    --output text

echo -e "${GREEN}✓ Play count is now incremented${NC}"
echo
echo "---"
echo

# Operation 3: Conditional update
echo -e "${BLUE}3. Conditional update - Only update if rating doesn't exist...${NC}"
echo "Command: aws dynamodb update-item with condition-expression"
echo "Trying to add rating to Miles Davis song only if Rating attribute doesn't exist"
echo

# This should succeed because Miles Davis song doesn't have a Rating
aws dynamodb update-item \
    --table-name Music \
    --key '{
        "Artist": {"S": "Miles Davis"},
        "SongTitle": {"S": "Kind of Blue"}
    }' \
    --update-expression "SET Rating = :rating" \
    --condition-expression "attribute_not_exists(Rating)" \
    --expression-attribute-values '{
        ":rating": {"N": "4"}
    }' \
    --return-values ALL_NEW \
    --output table

echo -e "${GREEN}✓ Conditional update succeeded${NC}"
echo

# Try the same conditional update again - this should fail
echo "Trying the same conditional update again (should fail)..."
if aws dynamodb update-item \
    --table-name Music \
    --key '{
        "Artist": {"S": "Miles Davis"},
        "SongTitle": {"S": "Kind of Blue"}
    }' \
    --update-expression "SET Rating = :rating" \
    --condition-expression "attribute_not_exists(Rating)" \
    --expression-attribute-values '{
        ":rating": {"N": "5"}
    }' 2>/dev/null; then
    echo -e "${RED}Unexpected: Conditional update should have failed${NC}"
else
    echo -e "${YELLOW}✓ Conditional update failed as expected (Rating already exists)${NC}"
fi

echo
echo "---"
echo

# Operation 4: Delete an item
echo -e "${BLUE}4. Deleting an item...${NC}"
echo "Command: aws dynamodb delete-item"
echo "Deleting 'Kind of Blue' by Miles Davis"
echo

# Show item before deletion
echo "Item before deletion:"
aws dynamodb get-item \
    --table-name Music \
    --key '{
        "Artist": {"S": "Miles Davis"},
        "SongTitle": {"S": "Kind of Blue"}
    }' \
    --query 'Item.{Artist:Artist.S,Song:SongTitle.S,Album:Album.S,Year:Year.N,Genre:Genre.S,Rating:Rating.N}' \
    --output table

echo
echo "Performing deletion..."

aws dynamodb delete-item \
    --table-name Music \
    --key '{
        "Artist": {"S": "Miles Davis"},
        "SongTitle": {"S": "Kind of Blue"}
    }'

echo -e "${GREEN}✓ Item deleted successfully${NC}"
echo

# Verify deletion
echo "Verifying deletion (should return empty result):"
RESULT=$(aws dynamodb get-item \
    --table-name Music \
    --key '{
        "Artist": {"S": "Miles Davis"},
        "SongTitle": {"S": "Kind of Blue"}
    }' \
    --output json)

if echo "$RESULT" | grep -q '"Item"'; then
    echo -e "${RED}✗ Item still exists (unexpected)${NC}"
else
    echo -e "${GREEN}✓ Item successfully deleted (no item returned)${NC}"
fi

echo
echo "---"
echo

# Show final state of table
echo -e "${BLUE}Final state of Music table:${NC}"
aws dynamodb scan --table-name Music --query 'Items[].{Artist:Artist.S,Song:SongTitle.S,Album:Album.S,Year:Year.N,Genre:Genre.S,Rating:Rating.N,PlayCount:PlayCount.N,LastPlayed:LastPlayed.S}' --output table

echo
echo -e "${GREEN}Step 4 completed successfully!${NC}"
echo
echo "Operations demonstrated:"
echo "  ✓ UpdateItem with SET - Add/modify attributes"
echo "  ✓ UpdateItem with ADD - Atomic counter operations"
echo "  ✓ Conditional Updates - Update only when conditions are met"
echo "  ✓ DeleteItem - Remove items from table"
echo "  ✓ Return Values - See item state before/after operations"
echo
echo "Key Takeaways:"
echo "  • Update expressions allow atomic modifications"
echo "  • ADD operations work great for counters"
echo "  • Conditional expressions prevent unwanted updates"
echo "  • Delete operations are immediate and permanent"
echo "  • Return values help verify operation success"
echo
echo "You can now proceed to the Python SDK examples or clean up the table."
