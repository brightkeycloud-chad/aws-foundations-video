#!/bin/bash

# Test script to demonstrate the artifact handling fix

echo "🧪 Testing artifact handling logic..."
echo ""

# Simulate the S3 listing output that was causing the issue
echo "📋 Simulating S3 listing output:"
echo "2025-08-04 20:09:23       2091 codebuild-demo-output.zip/target/messageUtil-1.0.jar"
echo ""

# Test the artifact key extraction
ARTIFACT_KEY="codebuild-demo-output.zip/target/messageUtil-1.0.jar"
LOCAL_FILENAME=$(basename "${ARTIFACT_KEY}")

echo "🔍 Testing filename extraction:"
echo "   S3 Key: ${ARTIFACT_KEY}"
echo "   Local filename: ${LOCAL_FILENAME}"
echo ""

# Test file extension detection
if [[ "$LOCAL_FILENAME" == *.zip ]]; then
    echo "📦 Detected as ZIP file - would extract contents"
elif [[ "$LOCAL_FILENAME" == *.jar ]]; then
    echo "☕ Detected as JAR file - would show JAR contents"
else
    echo "📄 Detected as other file type"
fi

echo ""
echo "✅ Artifact handling logic test completed!"
echo ""
echo "💡 Key improvements:"
echo "   • Uses basename() to get correct local filename"
echo "   • Handles both ZIP and JAR files appropriately"
echo "   • Verifies download before processing"
echo "   • Provides clear error messages"
