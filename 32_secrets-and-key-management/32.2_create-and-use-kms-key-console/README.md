# Create and Use KMS Key Console Demonstration

## Overview
This 5-minute demonstration shows how to create and use an AWS Key Management Service (KMS) customer-managed key through the AWS Console. You'll learn to create a symmetric encryption key, set permissions, and use it to encrypt/decrypt data.

## Prerequisites
- AWS account with appropriate permissions
- Access to AWS Management Console
- Basic understanding of encryption concepts

## Demonstration Steps

### Step 1: Navigate to AWS KMS (1 minute)
1. Sign in to the AWS Management Console
2. Navigate to **Key Management Service (KMS)**
3. Click on **Customer managed keys** in the left navigation panel
4. Click **Create key**

### Step 2: Configure Key Settings (1.5 minutes)
1. **Key type**: Select **Symmetric**
2. **Key usage**: Select **Encrypt and decrypt**
3. **Advanced options**: Leave as default (KMS)
4. Click **Next**

### Step 3: Add Key Details (1 minute)
1. **Alias**: Enter `demo-encryption-key`
2. **Description**: Enter "Demonstration key for encryption/decryption"
3. **Tags** (optional): Add any relevant tags
4. Click **Next**

### Step 4: Define Key Administrative Permissions (1 minute)
1. Select your current IAM user/role as key administrator
2. Allow key administrators to delete this key (check the box)
3. Click **Next**

### Step 5: Define Key Usage Permissions (0.5 minutes)
1. Select the same IAM user/role for key usage permissions
2. Click **Next**
3. Review the key policy (auto-generated)
4. Click **Finish**

### Step 6: Test Key Usage (1 minute)
1. Navigate to the newly created key
2. Click on the key alias `demo-encryption-key`
3. In the **General configuration** tab, note the Key ID and ARN
4. Scroll down to **Encryption and decryption** section
5. Click **Encrypt data**
6. Enter sample text: "This is sensitive data"
7. Click **Encrypt**
8. Copy the encrypted ciphertext
9. Click **Decrypt data**
10. Paste the ciphertext and click **Decrypt**
11. Verify the original text is displayed

## Key Learning Points
- KMS provides centralized key management
- Customer-managed keys offer full control over key policies
- Keys can be used programmatically via AWS SDKs and CLI
- Key rotation can be enabled for enhanced security
- CloudTrail logs all key usage for auditing

## Cleanup Instructions
After the demonstration, clean up resources:

1. Navigate to **KMS** > **Customer managed keys**
2. Select the `demo-encryption-key`
3. Click **Key actions** > **Schedule key deletion**
4. Set waiting period to **7 days** (minimum)
5. Type the key alias to confirm
6. Click **Schedule deletion**

**Note**: Keys cannot be immediately deleted and have a mandatory waiting period.

## Additional Resources and Citations

### AWS Documentation References
- [AWS Key Management Service Developer Guide](https://docs.aws.amazon.com/kms/latest/developerguide/)
- [Creating Keys in AWS KMS](https://docs.aws.amazon.com/kms/latest/developerguide/create-keys.html)
- [Using Key Policies in AWS KMS](https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html)
- [Encrypting and Decrypting Data](https://docs.aws.amazon.com/kms/latest/developerguide/encrypt-decrypt.html)

### Best Practices Documentation
- [AWS KMS Best Practices](https://docs.aws.amazon.com/kms/latest/developerguide/best-practices.html)
- [Monitoring AWS KMS Keys](https://docs.aws.amazon.com/kms/latest/developerguide/monitoring-overview.html)

## Troubleshooting
- If you cannot create keys, verify IAM permissions include `kms:CreateKey`
- If encryption/decryption fails, check key usage permissions
- For access denied errors, review the key policy configuration
