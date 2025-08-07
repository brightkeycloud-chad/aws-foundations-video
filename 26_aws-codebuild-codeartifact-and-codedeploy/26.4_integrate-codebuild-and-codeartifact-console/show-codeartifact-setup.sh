#!/bin/bash

# Helper script to show CodeArtifact setup instructions
# This provides guidance for the manual CodeArtifact configuration steps

set -e  # Exit on any error

echo "🏗️  CodeArtifact Setup Instructions"
echo "===================================="
echo ""

echo "📋 STEP 1: Create CodeArtifact Domain"
echo "-------------------------------------"
echo "1. Open AWS Console → CodeArtifact → Get started"
echo "2. Create Domain:"
echo "   - Domain name: demo-domain"
echo "   - Encryption key: Use AWS managed key"
echo "   - Click 'Create domain'"
echo ""

echo "📋 STEP 2: Create CodeArtifact Repository"
echo "-----------------------------------------"
echo "1. In the domain, create repository:"
echo "   - Repository name: demo-python-repo"
echo "   - Public upstream repositories: Select 'pypi-store'"
echo "   - Domain: demo-domain"
echo "   - Click 'Create repository'"
echo ""

echo "📋 STEP 3: Configure IAM Permissions"
echo "------------------------------------"
echo "1. Navigate to IAM → Roles"
echo "2. Find/create CodeBuild service role: CodeBuildServiceRole-CodeArtifactDemo"
echo "3. Add this inline policy (CodeBuildCodeArtifactPolicy):"
echo ""
cat << 'EOF'
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"codeartifact:GetAuthorizationToken",
				"codeartifact:GetRepositoryEndpoint",
				"codeartifact:ReadFromRepository",
				"logs:CreateLogGroup",
				"logs:CreateLogStream",
				"logs:PutLogEvents",
				"s3:GetObject",
				"s3:PutObject"
			],
			"Resource": "*"
		},
		{
			"Effect": "Allow",
			"Action": "sts:GetServiceBearerToken",
			"Resource": "*",
			"Condition": {
				"StringEquals": {
					"sts:AWSServiceName": "codeartifact.amazonaws.com"
				}
			}
		}
	]
}
EOF

echo ""
echo "📋 STEP 4: Get Your AWS Account ID"
echo "----------------------------------"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null || echo "UNKNOWN")
if [ "$AWS_ACCOUNT_ID" != "UNKNOWN" ]; then
    echo "✅ Your AWS Account ID: ${AWS_ACCOUNT_ID}"
    echo "   (This will be used as AWS_ACCOUNT_ID environment variable in CodeBuild)"
else
    echo "❌ Could not determine AWS Account ID"
    echo "   Run: aws sts get-caller-identity --query Account --output text"
fi

echo ""
echo "📋 STEP 5: Verify CodeArtifact Resources"
echo "----------------------------------------"
echo "1. Domain: demo-domain"
echo "2. Repository: demo-python-repo"
echo "3. Upstream: pypi-store (for public PyPI packages)"
echo ""

echo "🔍 VERIFICATION COMMANDS:"
echo "------------------------"
echo "# List domains:"
echo "aws codeartifact list-domains"
echo ""
echo "# List repositories in domain:"
echo "aws codeartifact list-repositories --domain demo-domain"
echo ""
echo "# Get repository endpoint:"
echo "aws codeartifact get-repository-endpoint --domain demo-domain --repository demo-python-repo --format pypi"
echo ""

echo "✅ After completing these steps, proceed with CodeBuild project creation"
echo ""
echo "💡 The buildspec.yml file is configured to use:"
echo "   - Domain: demo-domain"
echo "   - Repository: demo-python-repo"
echo "   - Account ID from AWS_ACCOUNT_ID environment variable"
