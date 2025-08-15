#!/bin/bash

# AWS Cost Optimization Bonus Script
# This script identifies top 3 service costs and provides optimization recommendations

echo "💰 AWS Cost Optimization Analysis"
echo "================================="
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

# Query Cost Explorer for current month costs by service
echo "🔍 Querying AWS Cost Explorer for top service costs..."

# First get all the data
aws ce get-cost-and-usage \
    --time-period Start="$PREVIOUS_MONTH_START",End="$PREVIOUS_MONTH_END" \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --group-by Type=DIMENSION,Key=SERVICE \
    --output json > "$TEMP_FILE"

# Check if we got valid data
if [ ! -s "$TEMP_FILE" ] || ! jq -e '.ResultsByTime[0].Groups' "$TEMP_FILE" >/dev/null 2>&1; then
    echo "❌ Failed to retrieve cost data from AWS Cost Explorer."
    rm "$TEMP_FILE"
    exit 1
fi

# Process the data to filter and sort, handling null values properly
jq -r '.ResultsByTime[0].Groups 
    | map(select(.Metrics.BlendedCost.Amount != "0" and .Metrics.BlendedCost.Amount != null)) 
    | sort_by(.Metrics.BlendedCost.Amount | tonumber) 
    | reverse 
    | .[0:3]' "$TEMP_FILE" > "${TEMP_FILE}.filtered"

# Replace the original file with filtered data
mv "${TEMP_FILE}.filtered" "$TEMP_FILE"

# Check if we got data after filtering
if [ ! -s "$TEMP_FILE" ] || [ "$(cat "$TEMP_FILE")" = "null" ] || [ "$(cat "$TEMP_FILE")" = "[]" ]; then
    echo "❌ No cost data available for the previous month."
    echo "   This could mean:"
    echo "   • Cost Explorer is not enabled"
    echo "   • No AWS usage in previous month"
    echo "   • Data not yet available (wait 24 hours)"
    echo ""
    echo "🌐 Enable Cost Explorer manually:"
    echo "   https://console.aws.amazon.com/costmanagement/"
    rm "$TEMP_FILE"
    exit 1
fi

echo "✅ Cost data retrieved successfully!"
echo ""

# Parse and display top 3 services using a more robust approach
echo "🏆 TOP 3 SERVICE COSTS LAST MONTH:"
echo "=================================="

# Process each service individually to preserve spaces in names
SERVICE_COUNT=$(jq -r 'length' "$TEMP_FILE" 2>/dev/null || echo "0")

if [ "$SERVICE_COUNT" -eq 0 ]; then
    echo "❌ Unable to parse cost data. Please check manually in Cost Explorer."
    rm "$TEMP_FILE"
    exit 1
fi

TOTAL_COST=0

for i in $(seq 0 $((SERVICE_COUNT - 1))); do
    if [ $i -lt 3 ]; then
        # Use jq to extract individual service data, preserving spaces
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
                    echo "   💡 Optimization Tip: Consider Reserved Instances or Savings Plans"
                    echo "      • Reserved Instances can save up to 75% vs On-Demand"
                    echo "      • Right-size instances based on actual utilization"
                    echo "      • Use Spot Instances for fault-tolerant workloads"
                    ;;
                *"S3"*|*"Simple Storage Service"*)
                    echo "   💡 Optimization Tip: Optimize storage classes and lifecycle"
                    echo "      • Use S3 Intelligent-Tiering for automatic optimization"
                    echo "      • Move infrequent data to S3 IA or Glacier"
                    echo "      • Enable S3 Transfer Acceleration only when needed"
                    ;;
                *"RDS"*|*"Relational Database Service"*)
                    echo "   💡 Optimization Tip: Right-size and optimize database usage"
                    echo "      • Use Reserved Instances for predictable workloads"
                    echo "      • Consider Aurora Serverless for variable workloads"
                    echo "      • Optimize storage type (gp3 vs gp2)"
                    ;;
                *"Lambda"*)
                    echo "   💡 Optimization Tip: Optimize function configuration"
                    echo "      • Right-size memory allocation (affects CPU and cost)"
                    echo "      • Use ARM-based Graviton2 processors (up to 34% better price/performance)"
                    echo "      • Optimize function duration and reduce cold starts"
                    ;;
                *"CloudFront"*)
                    echo "   💡 Optimization Tip: Optimize content delivery"
                    echo "      • Use appropriate price classes for your audience"
                    echo "      • Enable compression to reduce data transfer"
                    echo "      • Optimize cache behaviors and TTL settings"
                    ;;
                *"EBS"*|*"Elastic Block Store"*)
                    echo "   💡 Optimization Tip: Optimize storage performance and cost"
                    echo "      • Migrate from gp2 to gp3 volumes (up to 20% cost savings)"
                    echo "      • Delete unused snapshots and volumes"
                    echo "      • Use appropriate volume types for workload requirements"
                    ;;
                *"NAT Gateway"*)
                    echo "   💡 Optimization Tip: Reduce data transfer costs"
                    echo "      • Consider NAT instances for lower traffic scenarios"
                    echo "      • Use VPC endpoints to avoid NAT Gateway charges"
                    echo "      • Optimize data transfer patterns within VPC"
                    ;;
                *"ELB"*|*"Load Balancing"*|*"Elastic Load Balancing"*)
                    echo "   💡 Optimization Tip: Optimize load balancer usage"
                    echo "      • Use Application Load Balancer for HTTP/HTTPS traffic"
                    echo "      • Consolidate multiple load balancers where possible"
                    echo "      • Consider using AWS Global Accelerator for global traffic"
                    ;;
                *"Security Hub"*)
                    echo "   💡 Optimization Tip: Optimize security monitoring costs"
                    echo "      • Review enabled security standards and disable unused ones"
                    echo "      • Optimize finding aggregation settings"
                    echo "      • Consider regional vs multi-region deployment"
                    ;;
                *"Amazon Q"*)
                    echo "   💡 Optimization Tip: Optimize AI assistant usage"
                    echo "      • Monitor usage patterns and adjust subscription if needed"
                    echo "      • Review user access and remove inactive users"
                    echo "      • Optimize query patterns for efficiency"
                    ;;
                *)
                    echo "   💡 General Optimization Tips:"
                    echo "      • Review usage patterns and right-size resources"
                    echo "      • Consider Reserved capacity for predictable workloads"
                    echo "      • Use AWS Cost Explorer recommendations"
                    ;;
            esac
        fi
    fi
done

echo ""
echo "📈 ADDITIONAL COST OPTIMIZATION STRATEGIES:"
echo "==========================================="
echo ""
echo "🔍 Immediate Actions:"
echo "   • Review AWS Cost Explorer recommendations"
echo "   • Set up billing alerts and budgets"
echo "   • Enable AWS Cost Anomaly Detection"
echo "   • Use AWS Trusted Advisor cost optimization checks"
echo ""
echo "📊 Long-term Strategies:"
echo "   • Implement cost allocation tags for better tracking"
echo "   • Regular right-sizing reviews (monthly/quarterly)"
echo "   • Consider multi-year Reserved Instance commitments"
echo "   • Evaluate Savings Plans for compute workloads"
echo ""
echo "🛠️ Tools and Resources:"
echo "   • AWS Cost Explorer: https://console.aws.amazon.com/costmanagement/"
echo "   • AWS Pricing Calculator: https://calculator.aws/"
echo "   • AWS Well-Architected Cost Optimization Pillar"
echo "   • AWS Cost Optimization Hub"
echo ""

# Calculate total of top 3 services
TOTAL_TOP3=0
for i in "${!COSTS[@]}"; do
    if [ $i -lt 3 ]; then
        TOTAL_TOP3=$(echo "$TOTAL_TOP3 + ${COSTS[$i]}" | bc -l 2>/dev/null || echo "$TOTAL_TOP3")
    fi
done

if command -v bc &> /dev/null && [ "$TOTAL_TOP3" != "0" ]; then
    echo "💰 Total cost of top 3 services: \$$(printf "%.2f" "$TOTAL_TOP3")"
    echo ""
fi

echo "🎯 Next Steps:"
echo "   1. Review detailed usage in Cost Explorer console"
echo "   2. Implement one optimization recommendation this week"
echo "   3. Set up cost budgets with alerts"
echo "   4. Schedule monthly cost optimization reviews"
echo ""

# Cleanup
rm "$TEMP_FILE"

echo "✅ Cost optimization analysis complete!"
echo ""
echo "💡 Pro Tip: Run this script monthly to track your optimization progress!"
