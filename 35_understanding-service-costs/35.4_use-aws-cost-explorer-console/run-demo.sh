#!/bin/bash

# AWS Cost Explorer Console Demonstration Runner
# This script guides you through the complete demonstration

clear
echo "🎯 AWS Cost Explorer Console Demonstration"
echo "=========================================="
echo ""
echo "This script will guide you through a 5-minute demonstration of AWS Cost Explorer"
echo "using the AWS Management Console."
echo ""

# Function to wait for user input
wait_for_user() {
    echo "Press Enter to continue..."
    read -r
}

# Function to display step with timing
show_step() {
    local step_num=$1
    local step_title=$2
    local duration=$3
    
    echo ""
    echo "🔹 STEP $step_num: $step_title ($duration)"
    echo "$(printf '=%.0s' {1..50})"
}

echo "📋 Prerequisites Check:"
echo "   ✓ AWS account with some usage data"
echo "   ✓ Web browser available"
echo "   ✓ Internet connection"
echo ""

wait_for_user

# Step 1: Enable Cost Explorer
show_step "1" "Enable Cost Explorer" "1 minute"
echo ""
echo "🌐 Opening AWS Cost Management Console..."

# Open the console
if [[ "$OSTYPE" == "darwin"* ]]; then
    open "https://console.aws.amazon.com/costmanagement/"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v xdg-open > /dev/null; then
        xdg-open "https://console.aws.amazon.com/costmanagement/"
    fi
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    start "https://console.aws.amazon.com/costmanagement/"
fi

echo ""
echo "📋 Actions to perform in the console:"
echo "   1. Sign in to your AWS account if prompted"
echo "   2. In the left navigation pane, click 'Cost Explorer'"
echo "   3. If you see 'Welcome to Cost Explorer', click 'Launch Cost Explorer'"
echo "   4. Mention that console access is free (API calls cost $0.01 each)"
echo ""
echo "💬 Speaking points:"
echo "   • Cost Explorer provides up to 13 months of historical data"
echo "   • Forecasting available for next 12 months"
echo "   • Data is typically available within 24 hours"
echo "   • Cost Anomaly Detection is automatically enabled"
echo ""

wait_for_user

# Step 2: Explore Dashboard
show_step "2" "Explore the Cost Explorer Dashboard" "2 minutes"
echo ""
echo "📊 Dashboard Overview - Point out these sections:"
echo ""
echo "   🔹 Month-to-date costs:"
echo "     • Shows current month spending"
echo "     • Compares with same period last month"
echo "     • Excludes refunds"
echo ""
echo "   🔹 Forecasted month end costs:"
echo "     • AI-powered prediction for month-end total"
echo "     • Compares with previous month actual costs"
echo "     • Helps with budget planning"
echo ""
echo "   🔹 Cost trends section:"
echo "     • Shows top 5 cost changes"
echo "     • Click on any trend to drill down"
echo "     • Click 'View all trends' for comprehensive analysis"
echo ""
echo "   🔹 Daily costs graph:"
echo "     • Visual representation of daily spending"
echo "     • Shows unblended costs by default"
echo "     • Data reflects usage up to previous day"
echo ""

wait_for_user

# Step 3: Use Cost Explorer Reports
show_step "3" "Use Cost Explorer Reports" "1.5 minutes"
echo ""
echo "🔍 Advanced Analysis - Demonstrate these features:"
echo ""
echo "   1. Click 'Explore costs' button (upper-right of daily graph)"
echo ""
echo "   2. Show default reports in left navigation:"
echo "      • Cost & Usage (comprehensive analysis)"
echo "      • Daily costs (granular daily view)"
echo "      • Monthly costs (monthly aggregation)"
echo ""
echo "   3. Demonstrate Filters panel:"
echo "      • Service: Filter by EC2, S3, Lambda, etc."
echo "      • Time range: Last 7 days, last month, custom"
echo "      • Linked accounts: If using AWS Organizations"
echo "      • Region: Analyze regional spending"
echo ""
echo "   4. Show 'Group by' options:"
echo "      • Service: See per-service breakdown"
echo "      • Usage Type: Detailed usage analysis"
echo "      • Region: Geographic cost distribution"
echo "      • Account: Multi-account analysis"
echo ""
echo "💬 Speaking points:"
echo "   • Filters help narrow down analysis to specific areas"
echo "   • Grouping reveals cost drivers and patterns"
echo "   • Data can be downloaded as CSV for further analysis"
echo ""

wait_for_user

# Step 4: Cost Views
show_step "4" "Understand Different Cost Views" "30 seconds"
echo ""
echo "💰 Cost View Types - Explain the differences:"
echo ""
echo "   🔹 Unblended Costs:"
echo "     • Standard on-demand pricing"
echo "     • No volume discounts applied"
echo "     • Good for understanding list prices"
echo ""
echo "   🔹 Amortized Costs:"
echo "     • Reserved Instance and Savings Plans costs"
echo "     • Upfront payments spread over time"
echo "     • Shows true cost allocation"
echo ""
echo "   🔹 Net Costs:"
echo "     • Actual costs after all discounts"
echo "     • Includes volume discounts and credits"
echo "     • Most accurate for actual spending"
echo ""
echo "📋 Actions:"
echo "   • Use the dropdown menu to switch between cost views"
echo "   • Compare the same time period across different views"
echo "   • Explain when to use each view type"
echo ""

wait_for_user

# Demo Summary
echo ""
echo "🎯 DEMONSTRATION COMPLETE!"
echo "========================="
echo ""
echo "✅ Key Points Covered:"
echo "   • How to enable Cost Explorer (free for console use)"
echo "   • Dashboard components and their meanings"
echo "   • Using filters and grouping for analysis"
echo "   • Understanding different cost view types"
echo "   • Cost trends and forecasting capabilities"
echo ""
echo "📚 Next Steps for Participants:"
echo "   • Set up cost budgets and alerts"
echo "   • Explore Reserved Instance recommendations"
echo "   • Create custom cost allocation tags"
echo "   • Consider Cost Anomaly Detection setup"
echo ""
echo "🔗 Additional Resources:"
echo "   • AWS Cost Management: https://console.aws.amazon.com/costmanagement/"
echo "   • Documentation: https://docs.aws.amazon.com/cost-management/latest/userguide/"
echo "   • AWS Pricing Calculator: https://calculator.aws/"
echo ""
echo "❓ Q&A Time - Ready for questions!"
echo ""

# Offer to run status check
echo "🔧 Would you like to run a Cost Explorer status check? (y/n)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Running Cost Explorer status check..."
    ./check-cost-explorer-status.sh
fi

echo ""
echo "Thank you for using the AWS Cost Explorer demonstration!"
