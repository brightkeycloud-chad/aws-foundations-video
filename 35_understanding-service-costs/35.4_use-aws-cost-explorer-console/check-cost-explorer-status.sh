#!/bin/bash

# AWS Cost Explorer Status Check Script
# This script helps verify if Cost Explorer is enabled and provides guidance

echo "🔍 AWS Cost Explorer Status Check"
echo "================================="
echo ""

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found. Please install AWS CLI to use this script."
    echo "   Installation guide: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    echo ""
    echo "🌐 Alternative: Check Cost Explorer status manually:"
    echo "   1. Open: https://console.aws.amazon.com/costmanagement/"
    echo "   2. Click 'Cost Explorer' in left navigation"
    echo "   3. If you see 'Welcome to Cost Explorer', it's not enabled yet"
    echo "   4. If you see the dashboard, it's already enabled"
    exit 1
fi

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS CLI not configured or no valid credentials found."
    echo "   Please run: aws configure"
    echo "   Or set up your AWS credentials"
    echo ""
    echo "🌐 Alternative: Check Cost Explorer status manually:"
    echo "   1. Open: https://console.aws.amazon.com/costmanagement/"
    echo "   2. Click 'Cost Explorer' in left navigation"
    echo "   3. If you see 'Welcome to Cost Explorer', it's not enabled yet"
    echo "   4. If you see the dashboard, it's already enabled"
    exit 1
fi

echo "✅ AWS CLI is configured"

# Get account information
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "📋 Account ID: $ACCOUNT_ID"
else
    echo "⚠️  Could not retrieve account information"
fi

echo ""

# Try to check Cost Explorer status using Cost Explorer API
echo "🔍 Checking Cost Explorer status..."

# Try a simple Cost Explorer API call to see if it's enabled
aws ce get-cost-and-usage \
    --time-period Start=2024-01-01,End=2024-01-02 \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --query 'ResultsByTime[0].Total.BlendedCost.Amount' \
    --output text &> /dev/null

if [ $? -eq 0 ]; then
    echo "✅ Cost Explorer appears to be enabled!"
    echo "   You can access it at: https://console.aws.amazon.com/costmanagement/home#/cost-explorer"
    echo ""
    echo "📊 Cost Explorer Features Available:"
    echo "   • Cost and usage analysis"
    echo "   • 13 months of historical data"
    echo "   • 12 months of forecasting"
    echo "   • Cost trends and anomaly detection"
    echo "   • Reserved Instance recommendations"
else
    echo "❓ Cost Explorer status unclear or not enabled"
    echo "   This could mean:"
    echo "   1. Cost Explorer is not yet enabled"
    echo "   2. Insufficient permissions to access Cost Explorer API"
    echo "   3. No cost data available yet (new account)"
    echo ""
    echo "🚀 To enable Cost Explorer:"
    echo "   1. Open: https://console.aws.amazon.com/costmanagement/"
    echo "   2. Click 'Cost Explorer' in left navigation"
    echo "   3. Click 'Launch Cost Explorer' button"
    echo "   4. Wait 24 hours for data to populate"
fi

echo ""
echo "📋 Required IAM Permissions for Cost Explorer:"
echo "   • ce:GetCostAndUsage"
echo "   • ce:GetDimensionValues"
echo "   • ce:GetReservationCoverage"
echo "   • ce:GetReservationUtilization"
echo "   • ce:GetUsageReport"
echo ""

echo "💡 Tips for the demonstration:"
echo "   • Ensure account has some AWS usage (even minimal)"
echo "   • Wait at least 24 hours after first AWS usage"
echo "   • Cost Explorer console access is free"
echo "   • API calls cost $0.01 each"
echo ""

echo "🔗 Useful Links:"
echo "   • Cost Management Console: https://console.aws.amazon.com/costmanagement/"
echo "   • Cost Explorer Direct: https://console.aws.amazon.com/costmanagement/home#/cost-explorer"
echo "   • Documentation: https://docs.aws.amazon.com/cost-management/latest/userguide/ce-what-is.html"
