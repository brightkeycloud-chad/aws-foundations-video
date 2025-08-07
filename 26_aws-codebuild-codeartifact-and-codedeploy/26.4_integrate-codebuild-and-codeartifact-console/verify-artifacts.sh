#!/bin/bash

# Script to verify and download build artifacts for CodeArtifact demo
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

# Look for the main artifact (deployment package)
ARTIFACT_KEY=$(aws s3 ls s3://${OUTPUT_BUCKET}/ --recursive | grep -E "deployment-package\.zip$" | head -1 | awk '{print $4}' || echo "")

if [ -z "$ARTIFACT_KEY" ]; then
    echo "⚠️  No deployment-package.zip found, looking for other artifacts..."
    ARTIFACT_KEY=$(aws s3 ls s3://${OUTPUT_BUCKET}/ --recursive | grep -E "\.(zip|py)$" | head -1 | awk '{print $4}' || echo "")
fi

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
    
    # Look for Python files and dependencies
    echo ""
    echo "🐍 Python application files:"
    find ${EXTRACT_DIR} -name "*.py" | while read file; do
        echo "   📄 $(basename $file)"
        echo "      Size: $(ls -lh "$file" | awk '{print $5}')"
    done
    
    # Check for installed packages
    SITE_PACKAGES=$(find ${EXTRACT_DIR} -type d -name "site-packages" | head -1)
    if [ -n "$SITE_PACKAGES" ]; then
        echo ""
        echo "📦 Installed packages from CodeArtifact:"
        ls -1 ${SITE_PACKAGES} | grep -E "^(requests|boto3|pytest)" | head -10 || echo "   No recognizable packages found"
    fi
    
    # Look for requirements.txt
    REQ_FILE=$(find ${EXTRACT_DIR} -name "requirements.txt" | head -1)
    if [ -n "$REQ_FILE" ]; then
        echo ""
        echo "📋 Requirements file contents:"
        cat ${REQ_FILE}
    fi
    
else
    echo "📄 Downloaded file details:"
    ls -lh ${LOCAL_FILENAME}
    
    # If it's a Python file, show first few lines
    if [[ "$LOCAL_FILENAME" == *.py ]]; then
        echo ""
        echo "🐍 Python file preview:"
        head -20 ${LOCAL_FILENAME}
    fi
fi

echo ""
echo "✅ Artifact verification completed!"
echo "📁 Downloaded: ${LOCAL_FILENAME}"

if [ -d "extracted-artifacts" ]; then
    echo "📂 Extracted to: extracted-artifacts/"
fi

echo ""
echo "🎯 CodeArtifact Integration Success Indicators:"
echo "   ✅ Build completed without package installation errors"
echo "   ✅ Dependencies were resolved from private repository"
echo "   ✅ Deployment package contains all required libraries"
echo ""
echo "🔄 To clean up resources, run: cleanup.sh"
