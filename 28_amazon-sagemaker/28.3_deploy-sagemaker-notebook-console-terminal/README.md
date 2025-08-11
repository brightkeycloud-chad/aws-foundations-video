# Deploy Amazon SageMaker AI Studio Environment Demo

## Overview
This 5-minute demonstration shows how to set up and use the modern Amazon SageMaker AI Studio experience (not Studio Classic). You'll create a SageMaker AI domain, launch the new Studio interface, and explore its integrated development environments including JupyterLab 4 and Code Editor.

## Prerequisites
- AWS Account with appropriate permissions
- AWS CLI configured with credentials
- Basic understanding of machine learning development environments

## Demo Steps (5 minutes)

### Step 1: Create SageMaker AI Domain via Console (2 minutes)

1. **Navigate to SageMaker AI Console**
   - Open AWS Console and search for "SageMaker"
   - Click on "Amazon SageMaker" service
   - Ensure you're using the modern SageMaker AI interface (not Classic)

2. **Create Domain using Quick Setup**
   - In the left navigation, click "Domains"
   - Click "Create domain"
   - Choose "Quick setup" (recommended for demos)
   - The quick setup will automatically:
     - Create a domain with name like `QuickSetupDomain-YYYYMMDDTHHMMSS`
     - Configure default execution role with necessary permissions
     - Set default experience to "Studio" (modern experience)
     - Enable Canvas and other SageMaker AI applications
   - Click "Create domain"

3. **Monitor Domain Creation**
   - Watch the status change from "Pending" to "InService" (takes 3-5 minutes)
   - Note: Quick setup creates the modern Studio experience with all applications enabled
   - The domain name will be automatically generated (e.g., `QuickSetupDomain-20250810T023045`)

### Step 2: Verify Domain Creation via Terminal (0.5 minutes)

1. **List SageMaker Domains**
   ```bash
   aws sagemaker list-domains --region us-east-1
   ```

2. **Get Domain Details (using the generated domain name)**
   ```bash
   # First, get the domain ID from the list command above
   aws sagemaker describe-domain --domain-id <domain-id-from-list> --region us-east-1
   ```
   
   **Note**: The domain name will be auto-generated like `QuickSetupDomain-20250810T023045`

### Step 3: Launch and Explore Modern Studio (2 minutes)

1. **Launch Studio**
   - Once domain status shows "InService", click the domain name
   - Click "Launch" next to your user profile
   - This opens the modern SageMaker AI Studio interface

2. **Explore the New Studio Interface**
   - **Home Dashboard**: Shows all your ML resources in one place
   - **Applications**: Multiple IDE options available:
     - JupyterLab (new version with faster startup)
     - Code Editor (based on VS Code)
     - Studio Classic (legacy option)
   - **Resources**: View training jobs, endpoints, models

3. **Launch JupyterLab Application**
   - Click "JupyterLab" from the applications section
   - Choose instance type: `ml.t3.medium`
   - Click "Run"
   - Wait for JupyterLab to start (faster than Classic)

4. **Quick JupyterLab Demo**
   - Create a new Python 3 notebook
   - Run a sample cell:
     ```python
     import sagemaker
     import boto3
     import pandas as pd
     
     print(f"SageMaker SDK version: {sagemaker.__version__}")
     print("Modern SageMaker AI Studio is ready!")
     
     # Show session info
     session = sagemaker.Session()
     print(f"Default bucket: {session.default_bucket()}")
     print(f"Region: {session.boto_region_name}")
     ```

### Step 4: Demonstrate Code Editor (0.5 minutes)

1. **Launch Code Editor**
   - Return to Studio home
   - Click "Code Editor" application
   - Choose same instance type: `ml.t3.medium`
   - Show the VS Code-like interface

2. **Key Features to Highlight**
   - Full VS Code experience in the browser
   - Integrated terminal
   - Git integration
   - Extension marketplace access

## Key Points to Highlight

- **Modern Experience**: New Studio is faster and more reliable than Studio Classic
- **Multiple IDEs**: Choose the right tool for your workflow (JupyterLab, Code Editor, etc.)
- **Unified Interface**: All SageMaker AI resources accessible from one dashboard
- **Better Performance**: Faster startup times and improved reliability
- **Full-Screen IDEs**: Each application opens in its own tab for better focus
- **Automatic Provisioning**: All configured applications created automatically

## Modern SageMaker AI Benefits

- **JupyterLab 4**: Latest version with enhanced features
- **Code Editor**: Full VS Code experience for MLOps workflows
- **Resource Management**: View all training jobs, endpoints, and models in one place
- **Simplified Deployment**: Deploy models directly from Studio interface
- **Enhanced JumpStart**: Better foundation model discovery and deployment

## Troubleshooting

- If domain creation fails, ensure you have the latest IAM permissions for SageMaker AI
- Quick setup automatically selects "Studio" (not "Studio Classic") as default experience
- Verify you're in a supported region for the new Studio experience
- Check that your account has sufficient service limits for SageMaker domains
- The cleanup script automatically finds domains starting with "QuickSetupDomain-"

## Migration Note

- Accounts created before November 30, 2023, may default to Studio Classic
- This demo uses the modern Studio experience (recommended)
- Studio Classic is still available as an application within the new Studio

## Next Steps

After this demo, participants can:
- Explore different IDE applications (JupyterLab, Code Editor, RStudio)
- Use the enhanced JumpStart for foundation models
- Deploy models using the simplified deployment workflows
- Connect local VS Code to SageMaker spaces
- Explore the unified resource management interface

## Citations and Documentation

1. [Amazon SageMaker AI Studio (New Experience)](https://docs.aws.amazon.com/sagemaker/latest/dg/studio-updated.html)
2. [Launch Amazon SageMaker Studio](https://docs.aws.amazon.com/sagemaker/latest/dg/studio-updated-launch.html)
3. [SageMaker Studio UI Overview](https://docs.aws.amazon.com/sagemaker/latest/dg/studio-updated-ui.html)
4. [Applications Supported in SageMaker Studio](https://docs.aws.amazon.com/sagemaker/latest/dg/studio-updated-apps.html)
5. [Migration from Studio Classic](https://docs.aws.amazon.com/sagemaker/latest/dg/studio-updated-migrate.html)
6. [SageMaker JupyterLab in Studio](https://docs.aws.amazon.com/sagemaker/latest/dg/studio-updated-jl.html)
