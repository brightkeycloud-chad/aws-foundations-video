# Assume an IAM Role Terminal Demonstration

## Overview
This 5-minute demonstration shows how to assume an IAM role using the AWS CLI and terminal. Role assumption allows users to temporarily gain different permissions or access resources in different AWS accounts using the AWS Security Token Service (STS).

## Prerequisites
- AWS CLI installed and configured
- IAM user with permissions to assume roles (`sts:AssumeRole`)
- An existing IAM role that can be assumed
- Basic understanding of IAM roles and policies
- Terminal/command line access

## Demonstration Steps (5 minutes)

### Step 1: Verify Current Identity (30 seconds)
1. Check your current AWS identity:
   ```bash
   aws sts get-caller-identity
   ```
   This shows your current user ARN, account ID, and user ID.

2. List your current permissions (if you have IAM read access):
   ```bash
   aws iam get-user
   ```

### Step 2: Create a Demo Role (1 minute)
*Note: This step can be pre-created for the demo*

1. Create a trust policy document:
   ```bash
   cat > trust-policy.json << 'EOF'
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Principal": {
           "AWS": "arn:aws:iam::ACCOUNT-ID:root"
         },
         "Action": "sts:AssumeRole",
         "Condition": {}
       }
     ]
   }
   EOF
   ```

2. Create the role (replace ACCOUNT-ID with your actual account ID):
   ```bash
   # Get your account ID
   ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
   
   # Update the trust policy with your account ID
   sed -i.bak "s/ACCOUNT-ID/$ACCOUNT_ID/g" trust-policy.json
   
   # Create the role
   aws iam create-role \
     --role-name DemoAssumeRole \
     --assume-role-policy-document file://trust-policy.json \
     --description "Demo role for assume role demonstration"
   ```

3. Attach a policy to the role:
   ```bash
   aws iam attach-role-policy \
     --role-name DemoAssumeRole \
     --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
   ```

### Step 3: Assume the Role Using AWS CLI (1.5 minutes)
1. Assume the role and capture the credentials:
   ```bash
   # Get your account ID
   ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
   
   # Assume the role
   aws sts assume-role \
     --role-arn "arn:aws:iam::$ACCOUNT_ID:role/DemoAssumeRole" \
     --role-session-name "demo-session-$(date +%s)" \
     --duration-seconds 3600
   ```

2. Extract and export the temporary credentials:
   ```bash
   # Store the assume-role output
   ROLE_OUTPUT=$(aws sts assume-role \
     --role-arn "arn:aws:iam::$ACCOUNT_ID:role/DemoAssumeRole" \
     --role-session-name "demo-session-$(date +%s)")
   
   # Extract credentials
   export AWS_ACCESS_KEY_ID=$(echo $ROLE_OUTPUT | jq -r '.Credentials.AccessKeyId')
   export AWS_SECRET_ACCESS_KEY=$(echo $ROLE_OUTPUT | jq -r '.Credentials.SecretAccessKey')
   export AWS_SESSION_TOKEN=$(echo $ROLE_OUTPUT | jq -r '.Credentials.SessionToken')
   
   echo "Temporary credentials exported!"
   ```

### Step 4: Verify Role Assumption (1 minute)
1. Check your new identity:
   ```bash
   aws sts get-caller-identity
   ```
   You should now see the assumed role ARN instead of your user ARN.

2. Test the role's permissions:
   ```bash
   # This should work (S3 read access)
   aws s3 ls
   
   # This should fail (no EC2 permissions)
   aws ec2 describe-instances
   ```

### Step 5: Using Profiles for Role Assumption (1 minute)
1. Configure a profile for the role in `~/.aws/config`:
   ```bash
   cat >> ~/.aws/config << EOF
   
   [profile demo-role]
   role_arn = arn:aws:iam::$ACCOUNT_ID:role/DemoAssumeRole
   source_profile = default
   region = us-east-1
   EOF
   ```

2. Use the profile to assume the role automatically:
   ```bash
   # AWS CLI automatically assumes the role when using this profile
   aws s3 ls --profile demo-role
   
   # Check identity with the profile
   aws sts get-caller-identity --profile demo-role
   ```

3. Set the profile as default for the session:
   ```bash
   export AWS_PROFILE=demo-role
   aws sts get-caller-identity
   ```

## Advanced Role Assumption Techniques

### 1. Role Assumption with MFA
```bash
# Assume role with MFA requirement
aws sts assume-role \
  --role-arn "arn:aws:iam::123456789012:role/SecureRole" \
  --role-session-name "mfa-session" \
  --serial-number "arn:aws:iam::123456789012:mfa/username" \
  --token-code 123456
```

### 2. Cross-Account Role Assumption
```bash
# Assume role in different account
aws sts assume-role \
  --role-arn "arn:aws:iam::DIFFERENT-ACCOUNT:role/CrossAccountRole" \
  --role-session-name "cross-account-session" \
  --external-id "unique-external-id"
```

### 3. Role Chaining
```bash
# First assume an intermediate role
aws sts assume-role \
  --role-arn "arn:aws:iam::123456789012:role/IntermediateRole" \
  --role-session-name "intermediate-session"

# Then assume the final role using the intermediate role's credentials
aws sts assume-role \
  --role-arn "arn:aws:iam::123456789012:role/FinalRole" \
  --role-session-name "final-session"
```

## Scripting Role Assumption

### Bash Script for Role Assumption
```bash
cat > assume-role.sh << 'EOF'
#!/bin/bash

# Function to assume a role and export credentials
assume_role() {
    local role_arn=$1
    local session_name=${2:-"cli-session-$(date +%s)"}
    local duration=${3:-3600}
    
    echo "Assuming role: $role_arn"
    
    # Assume the role
    local output=$(aws sts assume-role \
        --role-arn "$role_arn" \
        --role-session-name "$session_name" \
        --duration-seconds "$duration" 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        # Export the credentials
        export AWS_ACCESS_KEY_ID=$(echo "$output" | jq -r '.Credentials.AccessKeyId')
        export AWS_SECRET_ACCESS_KEY=$(echo "$output" | jq -r '.Credentials.SecretAccessKey')
        export AWS_SESSION_TOKEN=$(echo "$output" | jq -r '.Credentials.SessionToken')
        
        echo "✅ Successfully assumed role!"
        echo "Session expires: $(echo "$output" | jq -r '.Credentials.Expiration')"
        
        # Verify the assumption
        aws sts get-caller-identity
    else
        echo "❌ Failed to assume role"
        return 1
    fi
}

# Usage example
if [ $# -eq 0 ]; then
    echo "Usage: $0 <role-arn> [session-name] [duration-seconds]"
    echo "Example: $0 arn:aws:iam::123456789012:role/MyRole my-session 3600"
    exit 1
fi

assume_role "$@"
EOF

chmod +x assume-role.sh
```

### Python Script for Role Assumption
```bash
cat > assume_role.py << 'EOF'
#!/usr/bin/env python3
import boto3
import json
import os
import sys
from datetime import datetime

def assume_role(role_arn, session_name=None, duration=3600):
    """Assume an IAM role and return temporary credentials"""
    
    if not session_name:
        session_name = f"python-session-{int(datetime.now().timestamp())}"
    
    try:
        # Create STS client
        sts_client = boto3.client('sts')
        
        # Assume the role
        response = sts_client.assume_role(
            RoleArn=role_arn,
            RoleSessionName=session_name,
            DurationSeconds=duration
        )
        
        credentials = response['Credentials']
        
        # Set environment variables
        os.environ['AWS_ACCESS_KEY_ID'] = credentials['AccessKeyId']
        os.environ['AWS_SECRET_ACCESS_KEY'] = credentials['SecretAccessKey']
        os.environ['AWS_SESSION_TOKEN'] = credentials['SessionToken']
        
        print(f"✅ Successfully assumed role: {role_arn}")
        print(f"Session expires: {credentials['Expiration']}")
        
        # Verify the assumption
        identity = sts_client.get_caller_identity()
        print(f"Current identity: {identity['Arn']}")
        
        return credentials
        
    except Exception as e:
        print(f"❌ Failed to assume role: {e}")
        return None

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 assume_role.py <role-arn> [session-name] [duration]")
        sys.exit(1)
    
    role_arn = sys.argv[1]
    session_name = sys.argv[2] if len(sys.argv) > 2 else None
    duration = int(sys.argv[3]) if len(sys.argv) > 3 else 3600
    
    assume_role(role_arn, session_name, duration)
EOF

chmod +x assume_role.py
```

## Best Practices

### 1. Session Naming
- Use descriptive session names for auditing
- Include timestamp or user identifier
- Follow your organization's naming conventions

### 2. Duration Management
- Use minimum required duration
- Default is 1 hour, maximum depends on role configuration
- Consider token refresh for long-running processes

### 3. Security Considerations
- Always use MFA for sensitive roles
- Implement external ID for cross-account access
- Use condition keys in trust policies
- Monitor role usage with CloudTrail

### 4. Credential Management
- Never log or store temporary credentials
- Clear credentials when done
- Use profiles instead of environment variables when possible

## Troubleshooting Common Issues

### 1. Access Denied Errors
```bash
# Check if you have permission to assume the role
aws iam simulate-principal-policy \
  --policy-source-arn $(aws sts get-caller-identity --query Arn --output text) \
  --action-names sts:AssumeRole \
  --resource-arns "arn:aws:iam::123456789012:role/MyRole"
```

### 2. Role Trust Policy Issues
```bash
# Check the role's trust policy
aws iam get-role --role-name MyRole --query 'Role.AssumeRolePolicyDocument'
```

### 3. Session Duration Errors
```bash
# Check the role's maximum session duration
aws iam get-role --role-name MyRole --query 'Role.MaxSessionDuration'
```

## Cleanup
```bash
# Unset temporary credentials
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
unset AWS_PROFILE

# Delete the demo role (optional)
aws iam detach-role-policy \
  --role-name DemoAssumeRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess

aws iam delete-role --role-name DemoAssumeRole

# Remove temporary files
rm -f trust-policy.json trust-policy.json.bak
```

## Documentation References
1. [Using an IAM role in the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-role.html) - Complete guide to configuring and using IAM roles with AWS CLI
2. [Switch to an IAM role (AWS CLI)](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-cli.html) - Step-by-step role switching instructions
3. [assume-role — AWS CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/sts/assume-role.html) - Complete assume-role command documentation
4. [AWS STS examples using AWS CLI](https://docs.aws.amazon.com/code-library/latest/ug/cli_2_sts_code_examples.html) - STS service examples and use cases
5. [IAM tutorial: Delegate access across AWS accounts using IAM roles](https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_cross-account-with-roles.html) - Cross-account role delegation tutorial

## Additional Resources
- [AWS STS API Reference](https://docs.aws.amazon.com/STS/latest/APIReference/) - Complete STS API documentation
- [IAM Roles User Guide](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html) - Comprehensive IAM roles documentation
- [AWS Security Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html) - IAM security recommendations
- [AWS CloudTrail for Role Monitoring](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/) - Auditing role usage
