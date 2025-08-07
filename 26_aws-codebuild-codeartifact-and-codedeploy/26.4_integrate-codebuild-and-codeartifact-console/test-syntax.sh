#!/bin/bash

# Test script to verify CodeArtifact demo syntax and basic functionality

echo "🧪 Testing CodeArtifact demo syntax and basic functionality..."
echo ""

# Test 1: Syntax check
echo "1. Testing syntax..."
if bash -n run-demo.sh; then
    echo "   ✅ run-demo.sh syntax check passed"
else
    echo "   ❌ run-demo.sh syntax check failed"
    exit 1
fi

# Test 2: Check if all referenced scripts exist
echo ""
echo "2. Checking if all referenced scripts exist..."
scripts=("setup-project.sh" "create-s3-buckets.sh" "upload-source.sh" "create-codebuild-project.sh" "start-build.sh" "monitor-build.sh" "verify-artifacts.sh" "cleanup.sh" "show-codeartifact-setup.sh" "show-buildspec.sh")

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
files=("app.py" "test_app.py" "requirements.txt" "buildspec.yml")

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "   ✅ $file exists"
    else
        echo "   ❌ $file missing"
    fi
done

# Test 4: Validate Python syntax
echo ""
echo "4. Validating Python files..."
if command -v python3 >/dev/null 2>&1; then
    for py_file in app.py test_app.py; do
        if [ -f "$py_file" ]; then
            if python3 -m py_compile "$py_file" 2>/dev/null; then
                echo "   ✅ $py_file Python syntax OK"
            else
                echo "   ❌ $py_file Python syntax error"
            fi
        fi
    done
else
    echo "   ⚠️  Python3 not available, skipping Python syntax check"
fi

# Test 5: Validate buildspec YAML
echo ""
echo "5. Validating buildspec.yml..."
if command -v python3 >/dev/null 2>&1; then
    if python3 -c "import yaml; yaml.safe_load(open('buildspec.yml'))" 2>/dev/null; then
        echo "   ✅ buildspec.yml YAML syntax OK"
    else
        # Try basic YAML structure check without PyYAML
        if grep -q "version:" buildspec.yml && grep -q "phases:" buildspec.yml && grep -q "artifacts:" buildspec.yml; then
            echo "   ✅ buildspec.yml basic structure OK (PyYAML not available for full validation)"
        else
            echo "   ❌ buildspec.yml missing required sections"
        fi
    fi
else
    echo "   ⚠️  Python3 not available, skipping YAML validation"
fi

echo ""
echo "🎉 All tests completed!"
echo ""
echo "💡 To run the demo:"
echo "   ./run-demo.sh"
echo ""
echo "📋 Demo highlights:"
echo "   • Python application with AWS SDK integration"
echo "   • CodeArtifact private package repository"
echo "   • Automated testing with pytest"
echo "   • Lambda deployment package creation"
