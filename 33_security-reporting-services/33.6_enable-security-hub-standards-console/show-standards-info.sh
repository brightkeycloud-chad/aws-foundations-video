#!/bin/bash

# AWS Security Hub Standards Information Display Script
# This script shows current information about available Security Hub standards

set -e

echo "🛡️  AWS Security Hub Standards Overview (2025)"
echo "=============================================="

# Function to check if AWS CLI is configured
check_aws_cli() {
    if ! aws sts get-caller-identity &> /dev/null; then
        echo "❌ AWS CLI is not configured or credentials are invalid"
        echo "   This script will show general information without live data"
        LIVE_DATA=false
    else
        echo "✅ AWS CLI configured - will show live data where possible"
        LIVE_DATA=true
    fi
}

# Function to display standards information
display_standards_info() {
    echo ""
    echo "📋 Available Security Hub Standards (Current as of August 2025):"
    echo ""
    
    echo "1. 🏛️  AWS Foundational Security Best Practices (FSBP)"
    echo "   • Controls: 200+ comprehensive security controls"
    echo "   • Purpose: AWS's baseline security recommendations"
    echo "   • Best for: All AWS users as foundational security"
    echo "   • Coverage: All major AWS services"
    echo ""
    
    echo "2. 🏷️  AWS Resource Tagging Standard"
    echo "   • Controls: 10+ tagging-focused controls"
    echo "   • Purpose: Ensure proper resource tagging"
    echo "   • Best for: Governance, cost management, compliance"
    echo "   • Coverage: Resource identification and categorization"
    echo ""
    
    echo "3. 🌐 CIS AWS Foundations Benchmark"
    echo "   • Controls: 50+ foundational security controls"
    echo "   • Purpose: Industry-standard security configurations"
    echo "   • Best for: Organizations following CIS guidelines"
    echo "   • Coverage: Core AWS services with emphasis on foundations"
    echo ""
    
    echo "4. 🏛️  NIST SP 800-53 Revision 5"
    echo "   • Controls: 180+ federal security framework controls"
    echo "   • Purpose: Federal agency security requirements"
    echo "   • Best for: Government agencies, federal contractors"
    echo "   • Coverage: Comprehensive information system protection"
    echo ""
    
    echo "5. 🔒 NIST SP 800-171 Revision 2"
    echo "   • Controls: 110+ CUI protection controls"
    echo "   • Purpose: Controlled Unclassified Information protection"
    echo "   • Best for: Organizations handling federal CUI"
    echo "   • Coverage: Non-federal systems with federal data"
    echo ""
    
    echo "6. 💳 PCI DSS (Payment Card Industry Data Security Standard)"
    echo "   • Controls: 40+ payment security controls"
    echo "   • Purpose: Credit/debit card data protection"
    echo "   • Best for: Organizations processing card payments"
    echo "   • Coverage: Payment card data handling and storage"
    echo ""
    
    echo "7. 🏗️  Service-managed standard: AWS Control Tower"
    echo "   • Controls: 30+ governance controls"
    echo "   • Purpose: Multi-account environment governance"
    echo "   • Best for: Organizations using AWS Control Tower"
    echo "   • Coverage: Proactive and detective controls integration"
}

# Function to show industry recommendations
show_industry_recommendations() {
    echo ""
    echo "🏢 Industry-Specific Recommendations:"
    echo "===================================="
    echo ""
    echo "💰 Financial Services:"
    echo "   → FSBP + PCI DSS + CIS AWS Foundations"
    echo "   → Focus on data protection and regulatory compliance"
    echo ""
    echo "🏛️  Government/Federal:"
    echo "   → FSBP + NIST SP 800-53 + NIST SP 800-171"
    echo "   → Comprehensive federal security framework"
    echo ""
    echo "🏥 Healthcare:"
    echo "   → FSBP + CIS AWS Foundations + Resource Tagging"
    echo "   → Strong foundations with governance focus"
    echo ""
    echo "🏢 General Enterprise:"
    echo "   → FSBP + CIS AWS Foundations + Resource Tagging + Control Tower"
    echo "   → Comprehensive coverage with governance"
    echo ""
    echo "🛒 E-commerce/Retail:"
    echo "   → FSBP + PCI DSS + Resource Tagging"
    echo "   → Payment security with operational governance"
}

# Function to show live Security Hub status (if available)
show_live_status() {
    if [ "$LIVE_DATA" = true ]; then
        echo ""
        echo "🔍 Live Security Hub Status:"
        echo "============================"
        
        # Check if Security Hub is enabled
        if aws securityhub get-enabled-standards &> /dev/null; then
            echo "✅ Security Hub is enabled in this region"
            
            # Show enabled standards
            echo ""
            echo "📊 Currently Enabled Standards:"
            aws securityhub get-enabled-standards \
                --query 'StandardsSubscriptions[].{Name:StandardsArn,Status:StandardsStatus}' \
                --output table 2>/dev/null || echo "   No standards currently enabled"
            
        else
            echo "❌ Security Hub is not enabled in this region"
            echo "   Enable Security Hub to start using standards"
        fi
        
        # Show current region
        CURRENT_REGION=$(aws configure get region || echo "Not configured")
        echo ""
        echo "🌍 Current Region: $CURRENT_REGION"
        
    else
        echo ""
        echo "ℹ️  Configure AWS CLI to see live Security Hub status"
    fi
}

# Function to show demo tips
show_demo_tips() {
    echo ""
    echo "🎯 Demo Tips:"
    echo "============="
    echo ""
    echo "1. 🚀 Start with FSBP - most comprehensive baseline"
    echo "2. 🏷️  Add Resource Tagging - often overlooked but critical"
    echo "3. 🏢 Choose industry-specific standard based on audience"
    echo "4. 📊 Compare control counts to show comprehensive coverage"
    echo "5. 🔍 Drill into specific controls to show remediation guidance"
    echo "6. ⏱️  Mention 30-minute initial scoring, 24-hour updates"
    echo "7. 🔄 Emphasize continuous monitoring vs. point-in-time assessment"
    echo ""
    echo "💡 Interactive Elements:"
    echo "   • Click through different standards to compare"
    echo "   • Show control categories (EC2, S3, IAM, etc.)"
    echo "   • Demonstrate remediation guidance"
    echo "   • Compare security scores across standards"
}

# Main execution
main() {
    check_aws_cli
    display_standards_info
    show_industry_recommendations
    show_live_status
    show_demo_tips
    
    echo ""
    echo "🎉 Security Hub Standards Demo Ready!"
    echo "====================================="
    echo ""
    echo "📖 Use this information during your demo to:"
    echo "   • Explain current available standards"
    echo "   • Show industry-specific recommendations"
    echo "   • Demonstrate comprehensive security coverage"
    echo ""
    echo "🔗 Security Hub Console: https://console.aws.amazon.com/securityhub/"
}

# Run main function
main
