#!/bin/bash

# Script to verify and download build artifacts
# This script checks the output bucket and downloads artifacts

set -e  # Exit on any error

echo "🔍 Verifying build artifacts..."

# Check if bucket names file exists
if [ ! -f "bucket-names.txt" ]; then
    echo "❌ Error: bucket-names.txt not found!"
    echo "   Please run create-s3-buckets.sh first"
    exit 1
fi

# Load bucket names
source bucket-names.txt

echo "🪣 Checking output bucket: ${OUTPUT_BUCKET}"
echo ""

# List contents of output bucket
echo "📋 Output bucket contents:"
if aws s3 ls s3://${OUTPUT_BUCKET}/ --recursive; then
    echo ""
else
    echo "❌ No artifacts found or bucket is empty"
    echo "   Make sure the build completed successfully"
    exit 1
fi

# Look for the main artifact
ARTIFACT_KEY=$(aws s3 ls s3://${OUTPUT_BUCKET}/ --recursive | grep -E "\.(zip|jar)$" | head -1 | awk '{print $4}' || echo "")

if [ -z "$ARTIFACT_KEY" ]; then
    echo "❌ No build artifacts found in output bucket"
    exit 1
fi

echo "📦 Found artifact: ${ARTIFACT_KEY}"

# Get the local filename (basename of the S3 key)
LOCAL_FILENAME=$(basename "${ARTIFACT_KEY}")

# Download the artifact
echo "⬇️  Downloading artifact..."
aws s3 cp s3://${OUTPUT_BUCKET}/${ARTIFACT_KEY} ./${LOCAL_FILENAME}

# Verify download
if [ ! -f "${LOCAL_FILENAME}" ]; then
    echo "❌ Failed to download artifact"
    exit 1
fi

echo "✅ Downloaded: ${LOCAL_FILENAME}"

# If it's a zip file, extract and examine contents
if [[ "$LOCAL_FILENAME" == *.zip ]]; then
    echo "📂 Extracting artifact contents..."
    
    # Create extraction directory
    EXTRACT_DIR="extracted-artifacts"
    mkdir -p ${EXTRACT_DIR}
    
    # Extract
    unzip -q ${LOCAL_FILENAME} -d ${EXTRACT_DIR}
    
    echo "📄 Artifact contents:"
    find ${EXTRACT_DIR} -type f | sort
    
    # Look for JAR file specifically
    JAR_FILE=$(find ${EXTRACT_DIR} -name "*.jar" | head -1)
    if [ -n "$JAR_FILE" ]; then
        echo ""
        echo "☕ Found JAR file: $(basename ${JAR_FILE})"
        echo "📊 JAR file details:"
        ls -lh ${JAR_FILE}
        
        # Show JAR contents
        echo ""
        echo "📋 JAR contents:"
        jar tf ${JAR_FILE} | head -10
        if [ $(jar tf ${JAR_FILE} | wc -l) -gt 10 ]; then
            echo "... and $(( $(jar tf ${JAR_FILE} | wc -l) - 10 )) more files"
        fi
    fi
else
    echo "📄 Downloaded file details:"
    ls -lh ${LOCAL_FILENAME}
    
    # If it's a JAR file, show its contents
    if [[ "$LOCAL_FILENAME" == *.jar ]]; then
        echo ""
        echo "📋 JAR contents:"
        jar tf ${LOCAL_FILENAME} | head -10
        if [ $(jar tf ${LOCAL_FILENAME} | wc -l) -gt 10 ]; then
            echo "... and $(( $(jar tf ${LOCAL_FILENAME} | wc -l) - 10 )) more files"
        fi
    fi
fi

echo ""
echo "✅ Artifact verification completed!"
echo "📁 Downloaded: ${LOCAL_FILENAME}"

if [ -d "extracted-artifacts" ]; then
    echo "📂 Extracted to: extracted-artifacts/"
fi

echo ""
echo "🔄 To clean up resources, run: cleanup.sh"
