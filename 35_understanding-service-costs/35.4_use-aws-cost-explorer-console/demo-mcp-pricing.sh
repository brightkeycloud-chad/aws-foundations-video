#!/bin/bash

# MCP Pricing Tools Demonstration Script
# This script shows how to use MCP pricing tools for cost optimization

echo "🔧 AWS MCP Pricing Tools Demonstration"
echo "======================================"
echo ""

echo "This script demonstrates how to use MCP (Model Context Protocol) pricing tools"
echo "to get real-time AWS pricing data for cost optimization recommendations."
echo ""

echo "📋 Available MCP Pricing Tools:"
echo "   • get_pricing_service_codes() - List all AWS services with pricing data"
echo "   • get_pricing_service_attributes() - Get filterable attributes for a service"
echo "   • get_pricing_attribute_values() - Get valid values for attributes"
echo "   • get_pricing() - Get detailed pricing information with filters"
echo "   • get_price_list_urls() - Get bulk pricing data download URLs"
echo ""

echo "💡 Example Usage in Cost Optimization:"
echo ""

echo "1️⃣ Find EC2 pricing for cost comparison:"
echo "   - Use get_pricing('AmazonEC2', 'us-east-1', filters) to get current EC2 pricing"
echo "   - Compare On-Demand vs Reserved Instance pricing"
echo "   - Identify cheaper instance types with similar performance"
echo ""

echo "2️⃣ Analyze S3 storage class pricing:"
echo "   - Use get_pricing('AmazonS3', 'us-east-1') to get S3 pricing"
echo "   - Compare Standard vs Standard-IA vs Glacier pricing"
echo "   - Calculate potential savings from lifecycle policies"
echo ""

echo "3️⃣ RDS cost optimization:"
echo "   - Use get_pricing('AmazonRDS', 'us-east-1') for database pricing"
echo "   - Compare different instance types and storage options"
echo "   - Calculate Reserved Instance savings"
echo ""

echo "🚀 Running Enhanced Cost Optimization Script..."
echo ""

# Check if Python script exists
if [ -f "./bonus-cost-optimization-mcp.py" ]; then
    echo "Executing MCP-powered cost optimization analysis..."
    python3 ./bonus-cost-optimization-mcp.py
else
    echo "❌ MCP-powered script not found. Running basic version..."
    if [ -f "./bonus-cost-optimization.sh" ]; then
        ./bonus-cost-optimization.sh
    else
        echo "❌ No cost optimization scripts found."
        echo "Please ensure the bonus scripts are in the current directory."
    fi
fi

echo ""
echo "🔗 MCP Integration Benefits:"
echo "   • Real-time pricing data from AWS Pricing API"
echo "   • Accurate cost comparisons and savings calculations"
echo "   • Current service attributes and pricing dimensions"
echo "   • Multi-region pricing comparisons"
echo "   • Historical pricing data access"
echo ""

echo "📚 Learn More:"
echo "   • AWS Pricing API: https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/price-changes.html"
echo "   • MCP Documentation: https://modelcontextprotocol.io/"
echo "   • AWS Cost Optimization: https://aws.amazon.com/aws-cost-management/"
