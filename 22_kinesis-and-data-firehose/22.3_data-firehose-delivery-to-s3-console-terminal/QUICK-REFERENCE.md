# Quick Reference - Data Firehose to S3 Demo

## Demo Flow (5 minutes)

### Console Setup (2.5 min)
1. **Create Stream** → Firehose Console → Create stream
2. **Configure** → Source: Direct PUT, Dest: S3, Name: `demo-firehose-stream`
3. **S3 Settings** → Bucket, Buffer: 1MB/60sec, Compression: GZIP
4. **Create** → Wait for Active status

### Console Test (1 min)
1. **Test Data** → "Start sending demo data" → Wait 30sec → Stop

### CLI Demo (1.5 min)
1. **List Streams** → `aws firehose list-delivery-streams`
2. **Single Record** → `aws firehose put-record --delivery-stream-name demo-firehose-stream --record '{"Data":"SGVsbG8gZnJvbSBBV1MgQ0xJIQ=="}'`
3. **Batch Records** → `aws firehose put-record-batch --delivery-stream-name demo-firehose-stream --records file://sample-records.json`
4. **Verify S3** → Check bucket for delivered files

## Key Commands

```bash
# List streams
aws firehose list-delivery-streams

# Single record
aws firehose put-record \
    --delivery-stream-name demo-firehose-stream \
    --record '{"Data":"SGVsbG8gZnJvbSBBV1MgQ0xJIQ=="}'

# Batch records
aws firehose put-record-batch \
    --delivery-stream-name demo-firehose-stream \
    --records file://sample-records.json

# Check status
aws firehose describe-delivery-stream \
    --delivery-stream-name demo-firehose-stream
```

## Files in Demo Directory
- `README.md` - Complete instructions
- `demo-commands.sh` - All CLI commands
- `sample-records.json` - Base64 encoded test data
- `sample-data-decoded.json` - Human-readable test data
- `QUICK-REFERENCE.md` - This file

## Cleanup
```bash
aws firehose delete-delivery-stream --delivery-stream-name demo-firehose-stream
aws s3 rm s3://your-bucket-name --recursive
aws s3 rb s3://your-bucket-name
```

## Troubleshooting
- Stream not Active? Wait 1-2 minutes
- No S3 data? Check buffer settings (1MB or 60 seconds)
- CLI errors? Check AWS credentials and region
