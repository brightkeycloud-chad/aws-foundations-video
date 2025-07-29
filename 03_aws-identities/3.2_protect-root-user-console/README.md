# AWS Root User Protection Demonstration (5 minutes)

## Overview
This demonstration shows how to secure the AWS root user account by enabling Multi-Factor Authentication (MFA) and implementing security best practices. The root user has complete access to all AWS services and resources, making its protection critical for account security.

## Learning Objectives
By the end of this demonstration, participants will understand:
- Why root user protection is essential
- How to enable MFA for the root user
- Best practices for root user account security
- How to access security credentials settings

## Prerequisites
- AWS account with root user access
- Mobile device or authenticator app (Google Authenticator, Authy, etc.)
- Access to the AWS Management Console

## Demonstration Steps (5 minutes)

### Step 1: Sign in as Root User (30 seconds)
1. Navigate to the [AWS Management Console](https://console.aws.amazon.com/)
2. Click "Sign in to the Console"
3. Select "Root user" and enter your root email address
4. Enter your root password and sign in

### Step 2: Access Security Credentials (30 seconds)
1. In the top-right corner, click on your account name
2. Select "Security credentials" from the dropdown menu
3. You'll see the "My security credentials" page

### Step 3: Enable MFA for Root User (3 minutes)
1. Scroll down to the "Multi-Factor Authentication (MFA)" section
2. Click "Assign MFA device"
3. In the wizard:
   - Enter a **Device name** (e.g., "MyPhone-MFA")
   - Select **Authenticator app**
   - Click **Next**

4. **Configure the MFA device:**
   - Click "Show QR code" to display the QR code
   - Open your authenticator app on your mobile device
   - Scan the QR code with your authenticator app
   - The app will generate a 6-digit code

5. **Complete MFA setup:**
   - Enter the first 6-digit code from your authenticator app in "MFA code 1"
   - Wait for the code to refresh (about 30 seconds)
   - Enter the new 6-digit code in "MFA code 2"
   - Click "Add MFA"

### Step 4: Verify MFA Configuration (30 seconds)
1. You should see your MFA device listed in the MFA section
2. The status should show as "Active"
3. Note the device name and type (Virtual MFA device)

### Step 5: Test MFA (30 seconds)
1. Sign out of the AWS console
2. Sign back in as the root user
3. After entering your password, you'll be prompted for an MFA code
4. Enter the current 6-digit code from your authenticator app
5. Successfully sign in to verify MFA is working

## Key Security Best Practices Covered
- **Enable MFA**: Adds an extra layer of security beyond just a password
- **Use Strong Passwords**: Ensure root password is complex and unique
- **Limit Root Usage**: Only use root user for tasks that specifically require it
- **Monitor Root Activity**: Regularly review CloudTrail logs for root user actions

## Important Notes
- **Backup your MFA**: Save the QR code or secret key securely in case you lose your device
- **Multiple MFA devices**: You can register up to 8 MFA devices for redundancy
- **Root user tasks**: Only use root user for billing, account closure, or other administrative tasks that require root access

## Troubleshooting
- **QR code won't scan**: Use "Show secret key" option and manually enter the key
- **MFA codes not working**: Ensure your device's time is synchronized
- **Lost MFA device**: Contact AWS Support with account verification information

## Next Steps
After securing the root user:
1. Create IAM users for daily operations
2. Assign appropriate permissions to IAM users
3. Avoid using root user for regular AWS tasks
4. Set up billing alerts and notifications

## Documentation References
- [AWS Account Root User](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_root-user.html)
- [Enable Virtual MFA Device for Root User](https://docs.aws.amazon.com/IAM/latest/UserGuide/enable-virt-mfa-for-root.html)
- [Multi-factor Authentication for AWS Account Root User](https://docs.aws.amazon.com/IAM/latest/UserGuide/enable-mfa-for-root.html)
- [Activate MFA for Your Root User](https://docs.aws.amazon.com/accounts/latest/reference/getting-started-step3.html)

---
*This demonstration is part of the AWS Foundations training series focusing on AWS Identity and Access Management (IAM) fundamentals.*
