#!/bin/bash

# AWS Cost Optimization Bonus Script - Fixed Version
# This script identifies top 3 service costs and provides optimization recommendations

echo "💰 AWS Cost Optimization Analysis (Fixed Version)"
echo "================================================="
echo ""

# Check if AWS CLI is installed and configured
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found. Please install AWS CLI first."
    echo "   Installation guide: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
fi

if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS CLI not configured. Please run: aws configure"
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "❌ jq not found. Please install jq for JSON processing."
    echo "   macOS: brew install jq"
    echo "   Ubuntu/Debian: sudo apt-get install jq"
    echo "   CentOS/RHEL: sudo yum install jq"
    exit 1
fi

# Get previous month's date range (more reliable than current month)
# Calculate previous month dates properly
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

echo "📊 Analyzing costs from $PREVIOUS_MONTH_START to $PREVIOUS_MONTH_END (Previous Month)"
echo "   💡 Using previous month data for more complete cost analysis"
echo ""

# Create temporary file for cost data
TEMP_FILE=$(mktemp)
TEMP_RAW=$(mktemp)

# Query Cost Explorer for current month costs by service
echo "🔍 Querying AWS Cost Explorer for top service costs..."

# Get raw data first
aws ce get-cost-and-usage \
    --time-period Start="$PREVIOUS_MONTH_START",End="$PREVIOUS_MONTH_END" \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --group-by Type=DIMENSION,Key=SERVICE \
    --output json > "$TEMP_RAW" 2>/dev/null

# Check if the command succeeded
if [ $? -ne 0 ]; then
    echo "❌ Failed to query AWS Cost Explorer. Please check:"
    echo "   • AWS CLI is configured correctly"
    echo "   • You have permissions to access Cost Explorer"
    echo "   • Cost Explorer is enabled in your account"
    rm -f "$TEMP_FILE" "$TEMP_RAW"
    exit 1
fi

# Check if we have valid JSON response
if ! jq -e '.ResultsByTime[0].Groups' "$TEMP_RAW" >/dev/null 2>&1; then
    echo "❌ Invalid response from Cost Explorer API."
    echo "   Raw response:"
    cat "$TEMP_RAW"
    rm -f "$TEMP_FILE" "$TEMP_RAW"
    exit 1
fi

# Process the data to filter out zero costs and sort properly
echo "📊 Processing cost data..."

jq -r '.ResultsByTime[0].Groups 
    | map(select(
        .Metrics.BlendedCost.Amount != null and 
        .Metrics.BlendedCost.Amount != "0" and 
        (.Metrics.BlendedCost.Amount | tonumber) > 0
    )) 
    | sort_by(.Metrics.BlendedCost.Amount | tonumber) 
    | reverse 
    | .[0:3]' "$TEMP_RAW" > "$TEMP_FILE" 2>/dev/null

# Check if we got any data after filtering
if [ ! -s "$TEMP_FILE" ] || [ "$(cat "$TEMP_FILE")" = "null" ] || [ "$(cat "$TEMP_FILE")" = "[]" ]; then
    echo "❌ No cost data available for the previous month."
    echo "   This could mean:"
    echo "   • Cost Explorer is not enabled"
    echo "   • No AWS usage in previous month (all costs are \$0.00)"
    echo "   • Data not yet available (wait 24 hours after first usage)"
    echo ""
    echo "🔍 Debug information:"
    echo "   Raw groups found: $(jq -r '.ResultsByTime[0].Groups | length' "$TEMP_RAW" 2>/dev/null || echo "0")"
    echo "   Non-zero groups: $(jq -r '.ResultsByTime[0].Groups | map(select(.Metrics.BlendedCost.Amount != "0")) | length' "$TEMP_RAW" 2>/dev/null || echo "0")"
    echo ""
    echo "🌐 Enable Cost Explorer manually:"
    echo "   https://console.aws.amazon.com/costmanagement/"
    rm -f "$TEMP_FILE" "$TEMP_RAW"
    exit 1
fi

echo "✅ Cost data retrieved and processed successfully!"
echo ""

# Parse and display top 3 services
echo "🏆 TOP 3 SERVICE COSTS LAST MONTH:"
echo "=================================="

# Read the JSON array and process each service
SERVICE_COUNT=$(jq -r 'length' "$TEMP_FILE" 2>/dev/null || echo "0")

if [ "$SERVICE_COUNT" -eq 0 ]; then
    echo "❌ No services with costs found after processing."
    rm -f "$TEMP_FILE" "$TEMP_RAW"
    exit 1
fi

TOTAL_COST=0

for i in $(seq 0 $((SERVICE_COUNT - 1))); do
    if [ $i -lt 3 ]; then
        SERVICE=$(jq -r ".[$i].Keys[0]" "$TEMP_FILE" 2>/dev/null)
        COST=$(jq -r ".[$i].Metrics.BlendedCost.Amount" "$TEMP_FILE" 2>/dev/null)
        RANK=$((i + 1))
        
        if [ "$SERVICE" != "null" ] && [ "$COST" != "null" ]; then
            echo ""
            echo "🥇 #$RANK: $SERVICE"
            echo "   💵 Cost: \$$(printf "%.2f" "$COST")"
            
            # Add to total cost
            TOTAL_COST=$(echo "$TOTAL_COST + $COST" | bc -l 2>/dev/null || echo "$TOTAL_COST")
            
            # Generate optimization recommendation based on service
            case "$SERVICE" in
                *"EC2"*|*"Elastic Compute Cloud"*)
                    echo "   💡 Optimization Tips:"
                    echo "      • Review instance utilization with CloudWatch metrics"
                    echo "      • Consider Reserved Instances (up to 75% savings)"
                    echo "      • Right-size instances based on actual usage"
                    echo "      • Use Spot Instances for fault-tolerant workloads"
                    ;;
                *"S3"*|*"Simple Storage Service"*)
                    echo "   💡 Optimization Tips:"
                    echo "      • Enable S3 Intelligent-Tiering for automatic optimization"
                    echo "      • Use lifecycle policies to move data to cheaper storage classes"
                    echo "      • Delete incomplete multipart uploads and old versions"
                    echo "      • Consider S3 Glacier for archival data (up to 80% cheaper)"
                    ;;
                *"RDS"*|*"Relational Database Service"*)
                    echo "   💡 Optimization Tips:"
                    echo "      • Purchase Reserved Instances for production databases"
                    echo "      • Right-size database instances based on utilization"
                    echo "      • Consider Aurora Serverless for variable workloads"
                    echo "      • Migrate from gp2 to gp3 storage (up to 20% savings)"
                    ;;
                *"Lambda"*)
                    echo "   💡 Optimization Tips:"
                    echo "      • Optimize memory allocation based on actual usage"
                    echo "      • Use ARM-based Graviton2 processors (34% better price/performance)"
                    echo "      • Reduce function execution time through code optimization"
                    echo "      • Remove unused functions and versions"
                    ;;
                *"CloudFront"*)
                    echo "   💡 Optimization Tips:"
                    echo "      • Use appropriate price classes for your audience"
                    echo "      • Enable compression to reduce data transfer"
                    echo "      • Optimize cache behaviors and TTL settings"
                    echo "      • Remove unused distributions"
                    ;;
                *"EBS"*|*"Elastic Block Store"*)
                    echo "   💡 Optimization Tips:"
                    echo "      • Migrate from gp2 to gp3 volumes (up to 20% savings)"
                    echo "      • Delete unused volumes and snapshots"
                    echo "      • Right-size volume capacity based on usage"
                    echo "      • Use appropriate volume types for workload requirements"
                    ;;
                *)
                    echo "   💡 General Optimization Tips:"
                    echo "      • Review usage patterns and right-size resources"
                    echo "      • Consider Reserved capacity for predictable workloads"
                    echo "      • Use AWS Cost Explorer recommendations"
                    echo "      • Implement cost allocation tags for better tracking"
                    ;;
            esac
        fi
    fi
done

echo ""
echo "📈 SUMMARY & RECOMMENDATIONS:"
echo "============================="

if command -v bc &> /dev/null && [ "$TOTAL_COST" != "0" ]; then
    echo "💰 Total cost of top 3 services: \$$(printf "%.2f" "$TOTAL_COST")"
    echo ""
fi

echo "🎯 Immediate Action Plan:"
echo "   1. Focus on your #1 cost service this week"
echo "   2. Set up AWS Budgets with alerts for these services"
echo "   3. Use AWS Cost Explorer recommendations"
echo "   4. Schedule monthly cost optimization reviews"
echo ""

echo "🛠️ Additional Tools & Resources:"
echo "   • AWS Cost Explorer: https://console.aws.amazon.com/costmanagement/"
echo "   • AWS Pricing Calculator: https://calculator.aws/"
echo "   • AWS Trusted Advisor: Cost optimization checks"
echo "   • AWS Well-Architected Cost Optimization Pillar"
echo ""

# Cleanup
rm -f "$TEMP_FILE" "$TEMP_RAW"

echo "✅ Cost optimization analysis complete!"
echo ""
echo "💡 Pro Tip: Run this script monthly to track your optimization progress!"
