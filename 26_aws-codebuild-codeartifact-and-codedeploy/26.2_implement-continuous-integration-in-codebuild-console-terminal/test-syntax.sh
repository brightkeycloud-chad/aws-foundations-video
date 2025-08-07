#!/bin/bash

# Test script to verify run-demo.sh syntax and basic functionality

echo "🧪 Testing run-demo.sh syntax and basic functionality..."
echo ""

# Test 1: Syntax check
echo "1. Testing syntax..."
if bash -n run-demo.sh; then
    echo "   ✅ Syntax check passed"
else
    echo "   ❌ Syntax check failed"
    exit 1
fi

# Test 2: Check if all referenced scripts exist
echo ""
echo "2. Checking if all referenced scripts exist..."
scripts=("setup-project.sh" "create-s3-buckets.sh" "upload-source.sh" "monitor-build.sh" "verify-artifacts.sh" "cleanup.sh" "show-buildspec.sh")

for script in "${scripts[@]}"; do
    if [ -f "$script" ]; then
        echo "   ✅ $script exists"
        # Test syntax of each script
        if bash -n "$script"; then
            echo "      ✅ $script syntax OK"
        else
            echo "      ❌ $script syntax error"
        fi
    else
        echo "   ❌ $script missing"
    fi
done

# Test 3: Check if source files exist
echo ""
echo "3. Checking if source files exist..."
files=("MessageUtil.java" "TestMessageUtil.java" "pom.xml" "buildspec.yml")

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "   ✅ $file exists"
    else
        echo "   ❌ $file missing"
    fi
done

echo ""
echo "🎉 All tests completed!"
echo ""
echo "💡 To run the demo:"
echo "   ./run-demo.sh"
