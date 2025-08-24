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

### Step 2: Create a Demo Role (30 seconds)
*Note: This step can be pre-created for the demo*

1. Run the automated setup script:
   ```bash
   ./create-demo-role.sh
   ```
   
   This script will:
   - Set up a Python virtual environment with boto3
   - Get your AWS account ID automatically
   - Create the trust policy with the correct account ID
   - Create the DemoAssumeRole IAM role
   - Attach the S3ReadOnlyAccess policy
   - Display the role ARN for use in the next steps

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
Use the provided bash script for automated role assumption:

```bash
./assume-role.sh arn:aws:iam::123456789012:role/MyRole my-session 3600
```

### Python Script for Role Assumption
Activate the virtual environment and use the Python script:

```bash
# Activate the virtual environment (created by setup script)
source venv/bin/activate

# Use the Python script
python3 assume_role.py arn:aws:iam::123456789012:role/MyRole my-session 3600
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

### Clean Up Demo Resources
After completing the demonstration, clean up the created resources:

```bash
./cleanup-demo-role.sh
```

### Clear Temporary Credentials
```bash
# Unset temporary credentials from environment
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
unset AWS_PROFILE

# Or start a new terminal session
```set AWS_ACCESS_KEY_ID
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
