# Create and Use Secret Console Terminal Demonstration

## Overview
This 5-minute demonstration shows how to create and manage secrets using AWS Secrets Manager through both the AWS Console and terminal (AWS CLI). You'll learn to store database credentials, retrieve them programmatically, and manage secret rotation.

## Prerequisites
- AWS account with appropriate permissions
- AWS CLI installed and configured
- Access to AWS Management Console
- Basic understanding of database credentials

## Demonstration Steps

### Step 1: Create Secret via Console (2 minutes)
1. Sign in to the AWS Management Console
2. Navigate to **AWS Secrets Manager**
3. Click **Store a new secret**
4. Select **Credentials for Amazon RDS database**
5. Enter the following credentials:
   - **User name**: `demo_user`
   - **Password**: `DemoPassword123!`
   - **Database**: `demo_database`
6. Click **Next**
7. **Secret name**: Enter `demo/database/credentials`
8. **Description**: Enter "Demo database credentials for training"
9. Click **Next**
10. **Automatic rotation**: Leave disabled for demo
11. Click **Next**
12. Review settings and click **Store**

### Step 2: Retrieve Secret via Terminal (1.5 minutes)
1. Open terminal/command prompt
2. Run the provided script to retrieve the secret:
   ```bash
   ./retrieve_secret.sh
   ```
3. Observe the JSON output containing the secret values
4. Run the script to get just the password:
   ```bash
   ./get_password.sh
   ```

### Step 3: Update Secret via Terminal (1 minute)
1. Run the script to update the secret:
   ```bash
   ./update_secret.sh
   ```
2. Verify the update in the AWS Console:
   - Refresh the Secrets Manager page
   - Click on the secret name
   - Check the **Secret value** tab

### Step 4: List and Describe Secrets (0.5 minutes)
1. Run the script to list all secrets:
   ```bash
   ./list_secrets.sh
   ```
2. Run the script to describe the specific secret:
   ```bash
   ./describe_secret.sh
   ```

## Key Learning Points
- Secrets Manager provides secure storage for sensitive data
- Secrets can be retrieved programmatically using AWS CLI/SDKs
- Automatic rotation helps maintain security
- Fine-grained access control through IAM policies
- Integration with RDS, Redshift, and other AWS services
- Versioning allows for safe secret updates

## Scripts Included
- `retrieve_secret.sh` - Retrieves the complete secret
- `get_password.sh` - Extracts just the password field
- `update_secret.sh` - Updates the secret with new values
- `list_secrets.sh` - Lists all secrets in the account
- `describe_secret.sh` - Shows metadata about the secret
- `cleanup.sh` - Removes the demo secret

## Additional Resources and Citations

### AWS Documentation References
- [AWS Secrets Manager User Guide](https://docs.aws.amazon.com/secretsmanager/latest/userguide/)
- [Creating and Managing Secrets](https://docs.aws.amazon.com/secretsmanager/latest/userguide/managing-secrets.html)
- [Retrieving Secrets](https://docs.aws.amazon.com/secretsmanager/latest/userguide/retrieving-secrets.html)
- [AWS CLI Secrets Manager Commands](https://docs.aws.amazon.com/cli/latest/reference/secretsmanager/)

### Best Practices Documentation
- [AWS Secrets Manager Best Practices](https://docs.aws.amazon.com/secretsmanager/latest/userguide/best-practices.html)
- [Rotating Secrets](https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotating-secrets.html)

## Troubleshooting
- If CLI commands fail, verify AWS credentials are configured
- For access denied errors, check IAM permissions for Secrets Manager
- If secret not found, verify the secret name and region
- For JSON parsing issues, ensure `jq` is installed for script functionality
