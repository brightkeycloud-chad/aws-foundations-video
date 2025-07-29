#!/bin/bash

# DynamoDB CLI Demonstration Script
# AWS Foundations Training - DynamoDB Table Operations

set -e  # Exit on any error

echo "🎵 DynamoDB CLI Demonstration"
echo "============================="
echo

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print step headers
print_step() {
    echo -e "${BLUE}$1${NC}"
    echo "----------------------------------------"
}

# Function to print success messages
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Function to print error messages
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Step 1: Create Table
print_step "Step 1: Creating Music table..."
aws dynamodb create-table \
    --table-name Music \
    --attribute-definitions \
        AttributeName=Artist,AttributeType=S \
        AttributeName=SongTitle,AttributeType=S \
    --key-schema \
        AttributeName=Artist,KeyType=HASH \
        AttributeName=SongTitle,KeyType=RANGE \
    --billing-mode PAY_PER_REQUEST \
    --table-class STANDARD > /dev/null

print_success "Table creation initiated"

# Wait for table to be active
echo "Waiting for table to become active..."
aws dynamodb wait table-exists --table-name Music
print_success "Table is now active"
echo

# Step 2: Add Items
print_step "Step 2: Adding sample music items..."

# Add The Beatles song
aws dynamodb put-item \
    --table-name Music \
    --item '{
        "Artist": {"S": "The Beatles"},
        "SongTitle": {"S": "Hey Jude"},
        "Album": {"S": "The Beatles 1967-1970"},
        "Year": {"N": "1968"},
        "Genre": {"S": "Rock"}
    }' > /dev/null

print_success "Added: Hey Jude by The Beatles"

# Add Queen song
aws dynamodb put-item \
    --table-name Music \
    --item '{
        "Artist": {"S": "Queen"},
        "SongTitle": {"S": "Bohemian Rhapsody"},
        "Album": {"S": "A Night at the Opera"},
        "Year": {"N": "1975"},
        "Genre": {"S": "Rock"}
    }' > /dev/null

print_success "Added: Bohemian Rhapsody by Queen"

# Add Miles Davis song (different attributes)
aws dynamodb put-item \
    --table-name Music \
    --item '{
        "Artist": {"S": "Miles Davis"},
        "SongTitle": {"S": "Kind of Blue"},
        "Album": {"S": "Kind of Blue"},
        "Year": {"N": "1959"},
        "Genre": {"S": "Jazz"},
        "Duration": {"N": "45"}
    }' > /dev/null

print_success "Added: Kind of Blue by Miles Davis"
echo

# Step 3: Query Operations
print_step "Step 3: Performing query operations..."

echo "Getting specific item (Hey Jude by The Beatles):"
aws dynamodb get-item \
    --table-name Music \
    --key '{
        "Artist": {"S": "The Beatles"},
        "SongTitle": {"S": "Hey Jude"}
    }' \
    --output table

echo
echo "Querying all songs by The Beatles:"
aws dynamodb query \
    --table-name Music \
    --key-condition-expression "Artist = :artist" \
    --expression-attribute-values '{
        ":artist": {"S": "The Beatles"}
    }' \
    --output table

echo

# Step 4: Update Operation
print_step "Step 4: Updating item..."

echo "Adding rating to Bohemian Rhapsody:"
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

echo

# Step 5: Scan Operation
print_step "Step 5: Scanning for Rock songs..."

aws dynamodb scan \
    --table-name Music \
    --filter-expression "Genre = :genre" \
    --expression-attribute-values '{
        ":genre": {"S": "Rock"}
    }' \
    --output table

echo

# Step 6: Delete Operation
print_step "Step 6: Deleting an item..."

aws dynamodb delete-item \
    --table-name Music \
    --key '{
        "Artist": {"S": "Miles Davis"},
        "SongTitle": {"S": "Kind of Blue"}
    }' > /dev/null

print_success "Deleted: Kind of Blue by Miles Davis"
echo

# Final verification
print_step "Final: Verifying remaining items..."
aws dynamodb scan --table-name Music --output table

echo
print_success "Demonstration completed!"
echo
echo "To clean up, run:"
echo "aws dynamodb delete-table --table-name Music"
