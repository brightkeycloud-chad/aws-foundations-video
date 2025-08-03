#!/bin/bash

# Amazon Data Firehose CLI Demo Commands
# This script contains the commands used in the demonstration
# Execute each section manually during the demo

echo "=== Amazon Data Firehose CLI Demo Commands ==="
echo ""

# Set variables for the demo
STREAM_NAME="demo-firehose-stream"
BUCKET_NAME="demo-firehose-bucket-$(date +%s)"

echo "Stream Name: $STREAM_NAME"
echo "Bucket Name: $BUCKET_NAME"
echo ""

echo "=== Step 1: List existing Firehose streams ==="
echo "Command: aws firehose list-delivery-streams"
echo ""

echo "=== Step 2: Send a single record ==="
echo "Command:"
cat << 'EOF'
aws firehose put-record \
    --delivery-stream-name demo-firehose-stream \
    --record '{"Data":"SGVsbG8gZnJvbSBBV1MgQ0xJIQ=="}'
EOF
echo ""
echo "Decoded data: 'Hello from AWS CLI!'"
echo ""

echo "=== Step 3: Send multiple records in batch ==="
echo "Command:"
cat << 'EOF'
aws firehose put-record-batch \
    --delivery-stream-name demo-firehose-stream \
    --records '[
        {"Data":"eyJldmVudCI6InVzZXJfbG9naW4iLCJ1c2VyX2lkIjoxMjMsInRpbWVzdGFtcCI6IjIwMjUtMDgtMDJUMDA6MDA6MDBaIn0="},
        {"Data":"eyJldmVudCI6InBhZ2VfdmlldyIsInBhZ2UiOiIvaG9tZSIsInVzZXJfaWQiOjEyMywidGltZXN0YW1wIjoiMjAyNS0wOC0wMlQwMDowMTowMFoifQ=="},
        {"Data":"eyJldmVudCI6InB1cmNoYXNlIiwicHJvZHVjdF9pZCI6NDU2LCJhbW91bnQiOjI5Ljk5LCJ1c2VyX2lkIjoxMjMsInRpbWVzdGFtcCI6IjIwMjUtMDgtMDJUMDA6MDI6MDBaIn0="}
    ]'
EOF
echo ""
echo "Decoded JSON records:"
echo '{"event":"user_login","user_id":123,"timestamp":"2025-08-02T00:00:00Z"}'
echo '{"event":"page_view","page":"/home","user_id":123,"timestamp":"2025-08-02T00:01:00Z"}'
echo '{"event":"purchase","product_id":456,"amount":29.99,"user_id":123,"timestamp":"2025-08-02T00:02:00Z"}'
echo ""

echo "=== Step 4: Check stream status ==="
echo "Command:"
cat << 'EOF'
aws firehose describe-delivery-stream \
    --delivery-stream-name demo-firehose-stream
EOF
echo ""

echo "=== Cleanup Commands (run after demo) ==="
echo "Command to delete Firehose stream:"
echo "aws firehose delete-delivery-stream --delivery-stream-name demo-firehose-stream"
echo ""
echo "Commands to clean up S3 bucket (replace with actual bucket name):"
echo "aws s3 rm s3://your-bucket-name --recursive"
echo "aws s3 rb s3://your-bucket-name"
echo ""

echo "=== Utility: Encode/Decode Base64 ==="
echo "To encode text to Base64:"
echo "echo 'Your text here' | base64"
echo ""
echo "To decode Base64:"
echo "echo 'SGVsbG8gZnJvbSBBV1MgQ0xJIQ==' | base64 -d"
echo ""

echo "=== Demo Complete ==="
