#!/bin/bash

echo "=== Advanced Lambda Features ==="

# Show available Lambda runtimes
echo "Available Lambda runtimes:"
aws lambda list-layers --query 'Layers[*].[LayerName,LatestMatchingVersion.Version]' --output table

# Show Lambda limits and quotas
echo "Lambda service quotas:"
aws service-quotas list-service-quotas \
    --service-code lambda \
    --query 'Quotas[?contains(QuotaName, `Concurrent`)].[QuotaName,Value]' \
    --output table 2>/dev/null || echo "Service quotas not available in this region"

# Show Lambda event source mappings
echo "Lambda event source mappings:"
aws lambda list-event-source-mappings --output table

echo "Lambda function URL configurations:"
aws lambda list-functions \
    --query 'Functions[*].[FunctionName,State]' \
    --output table
