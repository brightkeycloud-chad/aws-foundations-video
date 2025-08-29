#!/bin/bash

set -e

echo "🔄 Starting CodeDeploy Lambda update process..."

# Load Terraform outputs
if [ ! -f terraform-outputs.json ]; then
    echo "❌ terraform-outputs.json not found. Run ./scripts/deploy.sh first."
    exit 1
fi

FUNCTION_NAME=$(jq -r '.lambda_function_name.value' terraform-outputs.json)
APP_NAME=$(jq -r '.codedeploy_app_name.value' terraform-outputs.json)
DEPLOYMENT_GROUP=$(jq -r '.codedeploy_deployment_group.value' terraform-outputs.json)
S3_BUCKET=$(jq -r '.s3_bucket_name.value' terraform-outputs.json)

echo "📦 Packaging Lambda v2 code..."
cd lambda-code/v2
zip -r ../../lambda-v2.zip .
cd ../..

echo "⬆️  Uploading new version to S3..."
aws s3 cp lambda-v2.zip s3://$S3_BUCKET/lambda-v2.zip

echo "🔄 Publishing new Lambda version..."
NEW_VERSION=$(aws lambda update-function-code \
    --function-name $FUNCTION_NAME \
    --s3-bucket $S3_BUCKET \
    --s3-key lambda-v2.zip \
    --publish \
    --query 'Version' \
    --output text)

echo "📝 New Lambda version: $NEW_VERSION"

# Get current alias version
CURRENT_VERSION=$(aws lambda get-alias \
    --function-name $FUNCTION_NAME \
    --name live \
    --query 'FunctionVersion' \
    --output text)

echo "📝 Current alias version: $CURRENT_VERSION"

# Create updated appspec.yml with correct version numbers
cat > /tmp/appspec.yml << EOF
version: 0.0
Resources:
  - TargetService:
      Type: AWS::Lambda::Function
      Properties:
        Name: "$FUNCTION_NAME"
        Alias: "live"
        CurrentVersion: "$CURRENT_VERSION"
        TargetVersion: "$NEW_VERSION"
EOF

echo "⬆️  Uploading appspec.yml to S3..."
aws s3 cp /tmp/appspec.yml s3://$S3_BUCKET/appspec.yml

echo "🚀 Creating CodeDeploy deployment..."
DEPLOYMENT_ID=$(aws deploy create-deployment \
    --application-name $APP_NAME \
    --deployment-group-name $DEPLOYMENT_GROUP \
    --revision revisionType=S3,s3Location="{bucket=$S3_BUCKET,key=appspec.yml,bundleType=YAML}" \
    --query 'deploymentId' \
    --output text)

echo "📋 Deployment ID: $DEPLOYMENT_ID"

echo "⏳ Monitoring CodeDeploy deployment..."
while true; do
    STATUS=$(aws deploy get-deployment \
        --deployment-id $DEPLOYMENT_ID \
        --query 'deploymentInfo.status' \
        --output text)
    
    echo "📊 CodeDeploy status: $STATUS"
    
    if [ "$STATUS" = "Succeeded" ]; then
        echo "✅ CodeDeploy deployment completed successfully!"
        break
    elif [ "$STATUS" = "Failed" ] || [ "$STATUS" = "Stopped" ]; then
        echo "❌ CodeDeploy deployment failed!"
        aws deploy get-deployment \
            --deployment-id $DEPLOYMENT_ID \
            --query 'deploymentInfo.errorInformation' \
            --output table
        exit 1
    fi
    
    sleep 5
done

echo ""
echo "🧪 Test the updated function with:"
echo "aws lambda invoke --function-name $FUNCTION_NAME:live response.json && cat response.json"

# Cleanup temporary files
rm -f lambda-v2.zip /tmp/appspec.yml

echo ""
echo "🎉 CodeDeploy completed! This demonstrates:"
echo "   • AWS CodeDeploy for Lambda deployments"
echo "   • Blue/green deployment with traffic shifting"
echo "   • Automated rollback capabilities"
echo "   • Zero-downtime deployments"
