#!/bin/bash

# Debug script for Cost Explorer issues
# This script helps diagnose common Cost Explorer problems

echo "🔍 AWS Cost Explorer Debug Script"
echo "================================="
echo ""

# Check AWS CLI
echo "1️⃣ Checking AWS CLI..."
if command -v aws &> /dev/null; then
    AWS_VERSION=$(aws --version 2>&1)
    echo "   ✅ AWS CLI found: $AWS_VERSION"
else
    echo "   ❌ AWS CLI not found"
    exit 1
fi

# Check AWS credentials
echo ""
echo "2️⃣ Checking AWS credentials..."
if aws sts get-caller-identity &> /dev/null; then
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
    USER_ARN=$(aws sts get-caller-identity --query Arn --output text 2>/dev/null)
    echo "   ✅ AWS credentials configured"
    echo "   📋 Account ID: $ACCOUNT_ID"
    echo "   👤 User/Role: $USER_ARN"
else
    echo "   ❌ AWS credentials not configured or invalid"
    exit 1
fi

# Check jq
echo ""
echo "3️⃣ Checking jq (JSON processor)..."
if command -v jq &> /dev/null; then
    JQ_VERSION=$(jq --version 2>&1)
    echo "   ✅ jq found: $JQ_VERSION"
else
    echo "   ❌ jq not found - required for JSON processing"
    echo "   Install with: brew install jq (macOS) or sudo apt-get install jq (Ubuntu)"
fi

# Test basic Cost Explorer access
echo ""
echo "4️⃣ Testing Cost Explorer API access..."

# Use previous month for more reliable data - calculate properly
if command -v python3 &> /dev/null; then
    # Use Python for reliable cross-platform date calculation
    DATES=$(python3 -c "
from datetime import datetime, timedelta
import calendar

today = datetime.now()
# First day of current month
first_current = today.replace(day=1)
# Last day of previous month
last_previous = first_current - timedelta(days=1)
# First day of previous month
first_previous = last_previous.replace(day=1)

print(f'{first_previous.strftime(\"%Y-%m-%d\")} {last_previous.strftime(\"%Y-%m-%d\")}')
")
    PREVIOUS_MONTH_START=$(echo $DATES | cut -d' ' -f1)
    PREVIOUS_MONTH_END=$(echo $DATES | cut -d' ' -f2)
else
    # Fallback for systems without Python
    CURRENT_YEAR=$(date +%Y)
    CURRENT_MONTH=$(date +%m)
    
    if [ "$CURRENT_MONTH" = "01" ]; then
        PREVIOUS_YEAR=$((CURRENT_YEAR - 1))
        PREVIOUS_MONTH="12"
    else
        PREVIOUS_YEAR=$CURRENT_YEAR
        PREVIOUS_MONTH=$(printf "%02d" $((CURRENT_MONTH - 1)))
    fi
    
    PREVIOUS_MONTH_START="${PREVIOUS_YEAR}-${PREVIOUS_MONTH}-01"
    
    # Calculate last day of previous month
    case $PREVIOUS_MONTH in
        01|03|05|07|08|10|12) LAST_DAY="31" ;;
        04|06|09|11) LAST_DAY="30" ;;
        02) 
            # Check for leap year
            if [ $((PREVIOUS_YEAR % 4)) -eq 0 ] && { [ $((PREVIOUS_YEAR % 100)) -ne 0 ] || [ $((PREVIOUS_YEAR % 400)) -eq 0 ]; }; then
                LAST_DAY="29"
            else
                LAST_DAY="28"
            fi
            ;;
    esac
    
    PREVIOUS_MONTH_END="${PREVIOUS_YEAR}-${PREVIOUS_MONTH}-${LAST_DAY}"
fi

TEMP_FILE=$(mktemp)

echo "   📅 Testing date range: $PREVIOUS_MONTH_START to $PREVIOUS_MONTH_END (Previous Month)"
echo "   💡 Using previous month for more complete data"

aws ce get-cost-and-usage \
    --time-period Start="$PREVIOUS_MONTH_START",End="$PREVIOUS_MONTH_END" \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --output json > "$TEMP_FILE" 2>&1

if [ $? -eq 0 ]; then
    echo "   ✅ Cost Explorer API accessible"
    
    # Check if we have any data
    TOTAL_COST=$(jq -r '.ResultsByTime[0].Total.BlendedCost.Amount // "0"' "$TEMP_FILE" 2>/dev/null)
    echo "   💰 Total cost for period: \$$TOTAL_COST"
    
    # Test service grouping
    echo ""
    echo "5️⃣ Testing service-level data..."
    
    aws ce get-cost-and-usage \
        --time-period Start="$PREVIOUS_MONTH_START",End="$PREVIOUS_MONTH_END" \
        --granularity MONTHLY \
        --metrics BlendedCost \
        --group-by Type=DIMENSION,Key=SERVICE \
        --output json > "$TEMP_FILE" 2>&1
    
    if [ $? -eq 0 ]; then
        echo "   ✅ Service grouping works"
        
        # Count services
        SERVICE_COUNT=$(jq -r '.ResultsByTime[0].Groups | length' "$TEMP_FILE" 2>/dev/null || echo "0")
        NON_ZERO_COUNT=$(jq -r '.ResultsByTime[0].Groups | map(select(.Metrics.BlendedCost.Amount != "0")) | length' "$TEMP_FILE" 2>/dev/null || echo "0")
        
        echo "   📊 Total services found: $SERVICE_COUNT"
        echo "   💵 Services with non-zero costs: $NON_ZERO_COUNT"
        
        if [ "$NON_ZERO_COUNT" -gt 0 ]; then
            echo ""
            echo "   🏆 Top services with costs:"
            jq -r '.ResultsByTime[0].Groups 
                | map(select(.Metrics.BlendedCost.Amount != "0")) 
                | sort_by(.Metrics.BlendedCost.Amount | tonumber) 
                | reverse 
                | .[0:5] 
                | .[] 
                | "      • " + .Keys[0] + ": $" + .Metrics.BlendedCost.Amount' "$TEMP_FILE" 2>/dev/null
        else
            echo "   ⚠️  No services with costs found"
            echo "   This could mean:"
            echo "      • Very new account with no usage yet"
            echo "      • All usage is within free tier"
            echo "      • Cost data not yet processed (wait 24 hours)"
        fi
    else
        echo "   ❌ Service grouping failed"
        echo "   Error output:"
        cat "$TEMP_FILE"
    fi
    
else
    echo "   ❌ Cost Explorer API not accessible"
    echo "   Error output:"
    cat "$TEMP_FILE"
    echo ""
    echo "   Common causes:"
    echo "   • Cost Explorer not enabled (enable at https://console.aws.amazon.com/costmanagement/)"
    echo "   • Insufficient IAM permissions"
    echo "   • Account too new (wait 24 hours after first usage)"
fi

# Check IAM permissions
echo ""
echo "6️⃣ Checking IAM permissions..."

REQUIRED_PERMISSIONS=(
    "ce:GetCostAndUsage"
    "ce:GetDimensionValues"
    "ce:GetUsageReport"
)

echo "   Required permissions for Cost Explorer:"
for perm in "${REQUIRED_PERMISSIONS[@]}"; do
    echo "      • $perm"
done

echo ""
echo "7️⃣ Recommendations:"

if [ "$NON_ZERO_COUNT" -eq 0 ]; then
    echo "   🎯 To generate cost data for testing:"
    echo "      • Create a small EC2 instance (t2.micro)"
    echo "      • Upload a small file to S3"
    echo "      • Wait 24 hours for data to appear in Cost Explorer"
fi

echo "   📚 Useful links:"
echo "      • Enable Cost Explorer: https://console.aws.amazon.com/costmanagement/"
echo "      • IAM permissions guide: https://docs.aws.amazon.com/cost-management/latest/userguide/ce-access.html"
echo "      • Cost Explorer documentation: https://docs.aws.amazon.com/cost-management/latest/userguide/ce-what-is.html"

# Cleanup
rm -f "$TEMP_FILE"

echo ""
echo "✅ Debug analysis complete!"
