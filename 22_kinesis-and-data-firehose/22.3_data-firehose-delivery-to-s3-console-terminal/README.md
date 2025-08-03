# Amazon Data Firehose Delivery to S3 - Console and Terminal Demo

## Overview
This 5-minute demonstration shows how to create an Amazon Data Firehose delivery stream that sends streaming data to Amazon S3, using both the AWS Management Console and AWS CLI terminal commands.

## Prerequisites
- AWS account with appropriate permissions
- AWS CLI installed and configured
- Basic understanding of Amazon S3 and streaming data concepts

## Demo Timeline (5 minutes)

### Part 1: Create Firehose Delivery Stream via Console (2.5 minutes)

#### Step 1: Navigate to Firehose Console
1. Open the AWS Management Console
2. Navigate to **Amazon Data Firehose** service
3. Click **Create Firehose stream**

#### Step 2: Configure Source and Destination
1. **Choose source and destination:**
   - Source: **Direct PUT**
   - Destination: **Amazon S3**
   - Firehose stream name: `demo-firehose-stream`

#### Step 3: Configure S3 Destination Settings
1. **S3 bucket configuration:**
   - Choose an existing S3 bucket or create new one: `demo-firehose-bucket-[timestamp]`
   - S3 bucket prefix: `firehose-data/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/`
   - S3 bucket error output prefix: `firehose-errors/`

2. **Buffer settings:**
   - Buffer size: `1 MB` (minimum for demo)
   - Buffer interval: `60 seconds` (minimum for demo)

3. **Compression and encryption:**
   - Compression: **GZIP**
   - Encryption: **Disabled** (for demo simplicity)

#### Step 4: Configure Advanced Settings
1. **Error logging:** Enable CloudWatch error logging
2. **IAM role:** Create new service role or use existing
3. Click **Create Firehose stream**

### Part 2: Test with Sample Data via Console (1 minute)

#### Step 5: Send Test Data
1. Wait for stream status to become **Active** (30-60 seconds)
2. In the stream details page, scroll to **Test with demo data**
3. Click **Start sending demo data**
4. Observe the sample JSON stock ticker data being generated
5. After 30 seconds, click **Stop sending demo data**

### Part 3: Send Data via AWS CLI Terminal (1.5 minutes)

#### Step 6: Prepare Terminal Commands
Open terminal and prepare the following commands:

```bash
# Verify Firehose stream exists
aws firehose list-delivery-streams

# Send a single record
aws firehose put-record \
    --delivery-stream-name demo-firehose-stream \
    --record '{"Data":"SGVsbG8gZnJvbSBBV1MgQ0xJIQ=="}'

# Send multiple records using put-record-batch
aws firehose put-record-batch \
    --delivery-stream-name demo-firehose-stream \
    --records '[
        {"Data":"eyJldmVudCI6InVzZXJfbG9naW4iLCJ1c2VyX2lkIjoxMjMsInRpbWVzdGFtcCI6IjIwMjUtMDgtMDJUMDA6MDA6MDBaIn0="},
        {"Data":"eyJldmVudCI6InBhZ2VfdmlldyIsInBhZ2UiOiIvaG9tZSIsInVzZXJfaWQiOjEyMywidGltZXN0YW1wIjoiMjAyNS0wOC0wMlQwMDowMTowMFoifQ=="},
        {"Data":"eyJldmVudCI6InB1cmNoYXNlIiwicHJvZHVjdF9pZCI6NDU2LCJhbW91bnQiOjI5Ljk5LCJ1c2VyX2lkIjoxMjMsInRpbWVzdGFtcCI6IjIwMjUtMDgtMDJUMDA6MDI6MDBaIn0="}
    ]'
```

#### Step 7: Execute Commands
1. Run the `list-delivery-streams` command to verify stream exists
2. Execute the `put-record` command to send a single record
3. Execute the `put-record-batch` command to send multiple records
4. Show the JSON output confirming successful record ingestion

#### Step 8: Verify Data in S3
1. Navigate to S3 console
2. Open the destination bucket
3. Browse to the partitioned folder structure
4. Download and examine the delivered files
5. Show the compressed data and explain the buffering behavior

## Data Format Examples

### Base64 Encoded Data Used in CLI Commands:

**Single Record (decoded):**
```
Hello from AWS CLI!
```

**Batch Records (decoded JSON):**
```json
{"event":"user_login","user_id":123,"timestamp":"2025-08-02T00:00:00Z"}
{"event":"page_view","page":"/home","user_id":123,"timestamp":"2025-08-02T00:01:00Z"}
{"event":"purchase","product_id":456,"amount":29.99,"user_id":123,"timestamp":"2025-08-02T00:02:00Z"}
```

## Key Learning Points

1. **Buffering Behavior:** Data is buffered based on size (1MB) or time (60 seconds), whichever comes first
2. **Partitioning:** S3 objects are automatically partitioned by timestamp
3. **Compression:** GZIP compression reduces storage costs
4. **Multiple Input Methods:** Console demo data, CLI put-record, and put-record-batch
5. **Error Handling:** Failed records are sent to error prefix for troubleshooting

## Cleanup Instructions

```bash
# Delete the Firehose stream
aws firehose delete-delivery-stream --delivery-stream-name demo-firehose-stream

# Empty and delete the S3 bucket (if created for demo)
aws s3 rm s3://demo-firehose-bucket-[timestamp] --recursive
aws s3 rb s3://demo-firehose-bucket-[timestamp]
```

## Troubleshooting Tips

- **Stream not Active:** Wait 1-2 minutes after creation
- **No data in S3:** Check buffer settings and wait for buffer conditions to be met
- **CLI errors:** Verify AWS credentials and region configuration
- **Permission errors:** Ensure Firehose service role has S3 write permissions

## Cost Considerations

- Firehose charges per GB of data ingested
- S3 storage charges apply for delivered data
- CloudWatch logging incurs additional charges
- Use appropriate buffer settings to optimize costs

---

## Documentation References

1. [Tutorial: Create a Firehose stream from console](https://docs.aws.amazon.com/firehose/latest/dev/basic-create.html) - AWS Data Firehose Developer Guide
2. [Configure destination settings for Amazon S3](https://docs.aws.amazon.com/firehose/latest/dev/create-destination.html#create-destination-s3) - AWS Data Firehose Developer Guide  
3. [Testing Firehose stream with sample data](https://docs.aws.amazon.com/firehose/latest/dev/test-drive-firehose.html) - AWS Data Firehose Developer Guide
4. [Firehose examples using AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli_firehose_code_examples.html) - AWS CLI User Guide
5. [Use PutRecord with an AWS SDK or CLI](https://docs.aws.amazon.com/firehose/latest/dev/example_firehose_PutRecord_section.html) - AWS Data Firehose Developer Guide
6. [What is Amazon Data Firehose?](https://docs.aws.amazon.com/firehose/latest/dev/what-is-this-service.html) - AWS Data Firehose Developer Guide

---

*Demo Duration: 5 minutes | Skill Level: Beginner to Intermediate | Tools: AWS Console, AWS CLI*
