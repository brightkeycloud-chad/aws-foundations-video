# Integrate CodeBuild and CodeArtifact (Console)

## Demonstration Overview
This 5-minute demonstration shows how to integrate AWS CodeBuild with AWS CodeArtifact to manage package dependencies in a secure, private repository. You'll create a CodeArtifact repository, configure CodeBuild to use it, and demonstrate package management workflows using automated scripts with manual CodeArtifact setup.

## Prerequisites
- AWS Account with appropriate permissions
- Basic understanding of package management (Python/pip)
- AWS CLI configured
- Bash shell environment

## Demo Files Structure
```
26.4_integrate-codebuild-and-codeartifact-console/
├── README.md                    # This file
├── run-demo.sh                  # Main demo runner script
├── setup-project.sh             # Creates project structure
├── create-s3-buckets.sh         # Creates S3 buckets
├── upload-source.sh             # Uploads source to S3
├── create-codebuild-project.sh  # Creates CodeBuild project (AUTOMATED)
├── start-build.sh               # Starts CodeBuild build (AUTOMATED)
├── monitor-build.sh             # Monitors build progress
├── verify-artifacts.sh          # Downloads and verifies artifacts
├── cleanup.sh                   # Cleans up all resources
├── show-codeartifact-setup.sh   # Helper: CodeArtifact setup guide (MANUAL)
├── show-buildspec.sh            # Helper: Shows buildspec contents
├── test-syntax.sh               # Test: Validates all scripts
├── app.py                       # Sample Python Lambda function
├── test_app.py                  # Pytest test cases
├── requirements.txt             # Python dependencies
└── buildspec.yml                # CodeBuild build specification
```

## Quick Start (Recommended)

### Option 1: Guided Demo Runner
```bash
# Run the complete guided demonstration
./run-demo.sh
```
This script will walk you through all steps with explanations and pauses.

### Option 2: Manual Step-by-Step
Follow the individual steps below for more control.

**Manual Control Flow:**
```bash
./setup-project.sh              # 1. Setup Python project
./show-codeartifact-setup.sh    # 2. CodeArtifact guidance
# Manual: Create CodeArtifact domain and repository
./create-s3-buckets.sh          # 3. Create S3 buckets
./upload-source.sh              # 4. Upload source code
./create-codebuild-project.sh   # 5. Create CodeBuild project (AUTOMATED)
./start-build.sh                # 6. Start build (AUTOMATED)
./monitor-build.sh              # 7. Monitor build (optional)
./verify-artifacts.sh           # 8. Verify results
./cleanup.sh                    # 9. Cleanup
```

## Demonstration Steps

### Step 1: Prepare Sample Application (1 minute)

**Run the setup script:**
```bash
./setup-project.sh
```

**What this script does:**
- Creates the `codeartifact-demo` directory structure
- Copies all Python source files and configuration files
- Sets up the Python project structure

**Files created:**
- `app.py` - Python Lambda function with HTTP requests and AWS SDK usage
- `test_app.py` - Pytest test cases
- `requirements.txt` - Python dependencies (requests, boto3, pytest)
- `buildspec.yml` - CodeBuild specification with CodeArtifact integration

### Step 2: CodeArtifact Setup (Manual - 1.5 minutes)

**View setup instructions:**
```bash
./show-codeartifact-setup.sh
```

**Manual steps in AWS Console:**

1. **Create CodeArtifact Domain:**
   - Navigate to CodeArtifact Console → Get started
   - Domain name: `demo-domain`
   - Encryption key: Use AWS managed key
   - Click "Create domain"

2. **Create CodeArtifact Repository:**
   - Repository name: `demo-python-repo`
   - Public upstream repositories: Select `pypi-store`
   - Domain: `demo-domain`
   - Click "Create repository"

3. **Set Up IAM Permissions:**
   - Navigate to IAM → Roles
   - Find/create CodeBuild service role: `CodeBuildServiceRole-CodeArtifactDemo`
   - Add inline policy with CodeArtifact permissions (see helper script for details)

### Step 3: Create S3 Buckets (30 seconds)

**Run the S3 bucket creation script:**
```bash
./create-s3-buckets.sh
```

**What this script does:**
- Generates unique bucket names with timestamps
- Creates input bucket for source code
- Creates output bucket for build artifacts
- Saves bucket names to `bucket-names.txt` for other scripts

### Step 4: Upload Source Code (30 seconds)

**Run the upload script:**
```bash
./upload-source.sh
```

**What this script does:**
- Creates a zip archive of the Python project
- Uploads the archive to the S3 input bucket
- Verifies the upload was successful

### Step 5: Create CodeBuild Project (Automated - 30 seconds)

**Run the CodeBuild project creation script:**
```bash
./create-codebuild-project.sh
```

**What this script does:**
- Creates a CodeBuild service role with CodeArtifact permissions
- Configures S3 access for input and output buckets
- Sets up CloudWatch Logs permissions
- Creates the CodeBuild project with proper configuration
- Sets AWS_ACCOUNT_ID environment variable automatically

### Step 6: Start Build (Automated - 30 seconds)

**Run the build start script:**
```bash
./start-build.sh
```

**What this script does:**
- Starts a build of the CodeBuild project
- Provides the build ID for tracking
- Shows console and CLI monitoring options
- Saves build information for the monitoring script

### Step 7: Monitor Build Progress (1 minute)

**Optionally monitor via terminal:**
```bash
# Optional: Monitor build progress from command line
./monitor-build.sh
```

**What the monitoring script does:**
- Uses the build ID from the start-build script
- Continuously monitors build status with CodeArtifact-specific messaging
- Shows build details when complete

**Key things to watch for in build logs:**
- "Logging in to CodeArtifact..."
- "Successfully configured pip to use CodeArtifact"
- Package downloads from CodeArtifact URLs
- Test execution results

### Step 8: Verify Results (30 seconds)

**Run the artifact verification script:**
```bash
./verify-artifacts.sh
```

**What this script does:**
- Lists contents of the output S3 bucket
- Downloads the build artifacts (deployment package)
- Extracts and examines the contents
- Shows installed packages from CodeArtifact
- Verifies CodeArtifact integration success

### Step 9: Cleanup (30 seconds)

**Run the cleanup script:**
```bash
./cleanup.sh
```

**What this script does:**
- Prompts for confirmation
- Deletes S3 buckets and their contents
- Removes the CodeBuild project
- Deletes the CodeBuild service role and policies
- Cleans up all local files and directories
- **Note:** CodeArtifact resources require manual cleanup

## Script Details

### Individual Script Usage

**Setup Project:**
```bash
./setup-project.sh
# Creates project structure and copies Python files
```

**Show CodeArtifact Setup:**
```bash
./show-codeartifact-setup.sh
# Displays detailed CodeArtifact configuration instructions
```

**Show BuildSpec Contents:**
```bash
./show-buildspec.sh
# Displays buildspec.yml contents and explanation
```

**Create S3 Buckets:**
```bash
./create-s3-buckets.sh
# Creates unique S3 buckets and saves names
```

**Upload Source:**
```bash
./upload-source.sh
# Packages and uploads Python source code to S3
```

**Create CodeBuild Project:**
```bash
./create-codebuild-project.sh
# Automatically creates CodeBuild project with CodeArtifact integration
```

**Start Build:**
```bash
./start-build.sh
# Starts a CodeBuild build and provides monitoring information
```

**Monitor Build:**
```bash
./monitor-build.sh
# Monitors CodeBuild project status with CodeArtifact focus
```

**Verify Artifacts:**
```bash
./verify-artifacts.sh
# Downloads and examines build artifacts and packages
```

**Cleanup:**
```bash
./cleanup.sh
# Removes AWS resources and local files (CodeArtifact manual)
```

**Testing:**
```bash
./test-syntax.sh
# Validates syntax of all scripts and Python files
```

## Key Learning Points

- **Private Package Management:** Secure, controlled access to dependencies (MANUAL SETUP)
- **Authentication:** Automatic login to CodeArtifact from CodeBuild
- **Upstream Repositories:** Proxy to public repositories (PyPI)
- **Cost Optimization:** Caching reduces external bandwidth
- **Security:** Private packages stay within your AWS account
- **Integration:** Seamless workflow with existing CI/CD pipelines
- **Automation:** Scripts reduce manual errors and save time
- **IAM Management:** Automated service role creation with proper permissions
- **Infrastructure as Code:** Programmatic resource creation and management

## Demonstration Talking Points

1. **Security Benefits:** "Notice how packages are pulled from our private repository, not directly from the internet"
2. **Cost Efficiency:** "CodeArtifact caches packages, reducing bandwidth costs and improving build times"
3. **Compliance:** "All package downloads are logged and auditable"
4. **Reliability:** "Builds won't fail due to external package repository outages"
5. **Integration:** "The buildspec automatically authenticates with CodeArtifact using AWS credentials"

## Troubleshooting Tips

- **Permission Issues:** Ensure CodeBuild service role has CodeArtifact permissions
- **Script Errors:** Check that all scripts are executable (`chmod +x *.sh`)
- **Bucket Names:** Scripts generate unique names to avoid conflicts
- **Build Failures:** Check CloudWatch Logs for authentication issues
- **Missing Files:** Ensure all source files are present before running scripts
- **CodeArtifact Setup:** Verify domain and repository names match buildspec.yml
- **Account ID:** Ensure AWS_ACCOUNT_ID environment variable is set correctly
- **IAM Permissions:** Verify CodeBuild role has all required CodeArtifact actions

## IAM Role Configuration

The automated scripts create a CodeBuild service role named `CodeBuildServiceRole-CodeArtifactDemo` with the following configuration:

### **Trust Policy** (allows CodeBuild to assume the role):
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

### **Permissions Policy** (CodeArtifact + S3 + Logs):
```json
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
```

This policy provides the minimum required permissions for:
- **CodeArtifact access:** Authentication and package reading
- **S3 access:** Reading source code and writing artifacts
- **CloudWatch Logs:** Creating and writing build logs

## Advanced Usage

**Custom Configuration:**
- Modify `buildspec.yml` to change CodeArtifact domain/repository names
- Edit Python source files to test different scenarios
- Adjust `requirements.txt` for different dependencies

**Integration Testing:**
- Add more test cases to `test_app.py`
- Include integration tests in the build process
- Add code quality checks (e.g., pylint, black)

## File Contents

### buildspec.yml
The build specification includes CodeArtifact integration:
- **install:** Sets up Python 3.9 runtime
- **pre_build:** Logs into CodeArtifact and installs dependencies
- **build:** Runs pytest tests
- **post_build:** Creates Lambda deployment package

### app.py
Python Lambda function demonstrating:
- HTTP requests using the `requests` library
- AWS SDK usage with `boto3`
- JSON response formatting
- Error handling

### test_app.py
Pytest test cases demonstrating:
- Function testing
- Response structure validation
- Assertion usage

## Citations

1. [Using CodeArtifact with CodeBuild - CodeArtifact](https://docs.aws.amazon.com/codeartifact/latest/ug/codebuild.html)
2. [Using Python packages in CodeBuild - CodeArtifact](https://docs.aws.amazon.com/codeartifact/latest/ug/using-python-packages-in-codebuild.html)
3. [What is AWS CodeArtifact? - CodeArtifact](https://docs.aws.amazon.com/codeartifact/latest/ug/welcome.html)
4. [Getting started with CodeArtifact - CodeArtifact](https://docs.aws.amazon.com/codeartifact/latest/ug/getting-started.html)
5. [Build specification reference for CodeBuild - AWS CodeBuild](https://docs.aws.amazon.com/codebuild/latest/userguide/build-spec-ref.html)
