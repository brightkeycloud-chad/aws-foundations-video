#!/bin/bash

# Modern SageMaker Canvas Demo Setup Script
# This script helps prepare for the Canvas demonstration in the modern SageMaker AI Studio environment

set -e

REGION="us-east-1"

echo "🚀 Setting up Modern SageMaker Canvas Demo Environment"
echo "===================================================="
echo ""

echo "📋 Pre-Demo Checklist:"
echo ""

echo "1. ✅ Verify AWS CLI Configuration"
if aws sts get-caller-identity --region "$REGION" >/dev/null 2>&1; then
    echo "   AWS CLI is configured and working"
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    echo "   Account ID: $ACCOUNT_ID"
    echo "   Region: $REGION"
else
    echo "   ❌ AWS CLI not configured. Please run 'aws configure'"
    exit 1
fi
echo ""

echo "2. ✅ Check SageMaker AI Service Availability"
if aws sagemaker list-domains --region "$REGION" >/dev/null 2>&1; then
    echo "   SageMaker AI service is accessible"
else
    echo "   ❌ Cannot access SageMaker service. Check permissions."
    exit 1
fi
echo ""

echo "3. ✅ Verify Sample Data File"
if [ -f "sample-customer-data.csv" ]; then
    echo "   Sample dataset is available"
    ROWS=$(wc -l < sample-customer-data.csv)
    echo "   Dataset contains $ROWS rows (including header)"
else
    echo "   ❌ Sample dataset not found. Please ensure sample-customer-data.csv exists."
    exit 1
fi
echo ""

echo "4. 📊 Check for Existing SageMaker AI Domains"
DOMAINS=$(aws sagemaker list-domains --region "$REGION" --query 'Domains[].DomainName' --output text 2>/dev/null || echo "")

if [ -n "$DOMAINS" ]; then
    echo "   Found existing SageMaker AI domains:"
    echo "   $DOMAINS"
    echo ""
    
    # Check if any domains have Canvas enabled
    for domain_name in $DOMAINS; do
        DOMAIN_ID=$(aws sagemaker list-domains --region "$REGION" --query "Domains[?DomainName=='$domain_name'].DomainId" --output text)
        echo "   Checking Canvas permissions for domain: $domain_name"
        
        # Check domain settings (this is a simplified check)
        DOMAIN_SETTINGS=$(aws sagemaker describe-domain --domain-id "$DOMAIN_ID" --region "$REGION" --query 'DefaultUserSettings.CanvasAppSettings' --output text 2>/dev/null || echo "NotConfigured")
        
        if [ "$DOMAIN_SETTINGS" != "NotConfigured" ] && [ "$DOMAIN_SETTINGS" != "None" ]; then
            echo "   ✅ Canvas appears to be configured for domain: $domain_name"
        else
            echo "   ⚠️  Canvas may not be fully configured for domain: $domain_name"
        fi
    done
else
    echo "   No existing SageMaker AI domains found"
    echo "   ✅ Ready to create new domain with Canvas during demo"
fi
echo ""

echo "5. 🤖 Modern Canvas Features Check"
echo "   Modern Canvas includes:"
echo "   ✅ Generative AI chat with foundation models"
echo "   ✅ Ready-to-use models (Comprehend, Rekognition, Textract)"
echo "   ✅ Enhanced AutoML with business context"
echo "   ✅ Studio integration for unified ML workflow"
echo "   ✅ AI-powered data preparation and insights"
echo ""

echo "6. 💰 Cost Estimation (2024 Pricing)"
echo "   Modern Canvas pricing:"
echo "   - Canvas sessions: ~$1.90 per session hour"
echo "   - Quick Build: ~$0.25-$1.00 per model"
echo "   - Standard Build: ~$2.00-$10.00 per model"
echo "   - Generative AI chat: ~$0.002-$0.02 per 1K tokens"
echo "   - Ready-to-use models: Pay-per-API-call"
echo "   - Predictions: ~$0.001 per prediction"
echo ""

echo "7. 🕐 Time Requirements"
echo "   - SageMaker AI domain setup: 3-5 minutes (if needed)"
echo "   - Canvas application launch: 1-2 minutes"
echo "   - Data upload and analysis: 30 seconds"
echo "   - Quick model build: 2-4 minutes"
echo "   - Generative AI features: Instant"
echo "   - Total demo time: ~5 minutes (excluding domain setup)"
echo ""

echo "8. 🔐 Permissions Check"
echo "   Required permissions for modern Canvas:"
echo "   - SageMaker domain creation/access"
echo "   - Canvas application permissions"
echo "   - Foundation model access (for generative AI features)"
echo "   - S3 access for data storage"
echo "   - IAM role creation (if needed)"
echo ""

# Check if Bedrock is available (for generative AI features)
echo "9. 🧠 Generative AI Features Availability"
if aws bedrock list-foundation-models --region "$REGION" >/dev/null 2>&1; then
    echo "   ✅ Amazon Bedrock is accessible (generative AI features available)"
else
    echo "   ⚠️  Amazon Bedrock may not be accessible (generative AI features limited)"
    echo "   Note: Some Canvas AI features may be region-dependent"
fi
echo ""

echo "📚 Demo Resources Ready:"
echo "   - README.md: Complete modern Canvas demo instructions"
echo "   - sample-customer-data.csv: Sample dataset for upload"
echo "   - setup.sh: This pre-demo preparation script"
echo "   - cleanup.sh: Post-demo cleanup guidance"
echo ""

echo "🎯 Modern Canvas Demo Flow Summary:"
echo "   1. Access SageMaker Console → Domains → Launch Studio"
echo "   2. Click Canvas application in Studio"
echo "   3. Explore generative AI chat features"
echo "   4. Upload sample-customer-data.csv"
echo "   5. Create modern churn prediction model"
echo "   6. Review AI-powered insights and recommendations"
echo "   7. Demonstrate ready-to-use models"
echo "   8. Run cleanup.sh after demo"
echo ""

echo "✅ Setup complete! You're ready to run the modern Canvas demo."
echo ""
echo "💡 Pro Tips for Modern Canvas Demo:"
echo "   - Have the SageMaker Console open and ready"
echo "   - Bookmark the Studio interface"
echo "   - Keep the sample CSV file easily accessible"
echo "   - Prepare some sample prompts for the generative AI chat"
echo "   - Practice the Studio navigation once before presenting"
echo "   - Highlight the integration between Canvas and other Studio tools"
echo ""
echo "🆕 New Features to Emphasize:"
echo "   - Canvas is now part of the unified Studio experience"
echo "   - Generative AI capabilities for business insights"
echo "   - Enhanced AutoML with business-friendly explanations"
echo "   - Ready-to-use models for immediate value"
echo "   - Seamless integration with other SageMaker AI tools"
