# Implement Continuous Integration in CodeBuild (Console & Terminal)

## Demonstration Overview
This 5-minute demonstration shows how to implement continuous integration using AWS CodeBuild through both the AWS Console and terminal commands. You'll create a build project, configure a buildspec file, and execute builds to demonstrate CI/CD principles using automated scripts.

## Prerequisites
- AWS Account with appropriate permissions
- AWS CLI configured
- Basic understanding of CI/CD concepts
- Bash shell environment

## Demo Files Structure
```
26.2_implement-continuous-integration-in-codebuild-console-terminal/
├── README.md                    # This file
├── run-demo.sh                  # Main demo runner script
├── setup-project.sh             # Creates project structure
├── create-s3-buckets.sh         # Creates S3 buckets
├── upload-source.sh             # Uploads source to S3
├── monitor-build.sh             # Monitors build progress
├── verify-artifacts.sh          # Downloads and verifies artifacts
├── cleanup.sh                   # Cleans up all resources
├── show-buildspec.sh            # Helper: Shows buildspec contents
├── test-syntax.sh               # Test: Validates all scripts
├── test-artifact-handling.sh    # Test: Demonstrates artifact fix
├── MessageUtil.java             # Sample Java class
├── TestMessageUtil.java         # JUnit test class
├── pom.xml                      # Maven configuration
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

## Demonstration Steps

### Step 1: Prepare Sample Application (1 minute)

**Run the setup script:**
```bash
./setup-project.sh
```

**What this script does:**
- Creates the `codebuild-ci-demo` directory structure
- Copies all Java source files and configuration files
- Sets up the Maven project structure

**Files created:**
- `MessageUtil.java` - Main Java class with message utilities
- `TestMessageUtil.java` - JUnit test class
- `pom.xml` - Maven project configuration
- `buildspec.yml` - CodeBuild build specification

### Step 2: Create S3 Buckets (30 seconds)

**Run the S3 bucket creation script:**
```bash
./create-s3-buckets.sh
```

**What this script does:**
- Generates unique bucket names with timestamps
- Creates input bucket for source code
- Creates output bucket for build artifacts
- Saves bucket names to `bucket-names.txt` for other scripts

### Step 3: Upload Source Code (30 seconds)

**Run the upload script:**
```bash
./upload-source.sh
```

**What this script does:**
- Creates a zip archive of the project
- Uploads the archive to the S3 input bucket
- Verifies the upload was successful

### Step 4: Create CodeBuild Project (Console) (1.5 minutes)

**Manual step - Use AWS Console:**

1. **Navigate to CodeBuild Console:**
   - Open AWS Console → CodeBuild → Build projects → Create build project

2. **Project Configuration:**
   - **Project name:** `codebuild-ci-demo`
   - **Description:** `CI demonstration project`

3. **Source Configuration:**
   - **Source provider:** Amazon S3
   - **Bucket:** Use the input bucket name from `bucket-names.txt`
   - **S3 object key:** `codebuild-demo-source.zip`
   - **Source version:** Leave blank (uses latest)

4. **Environment Configuration:**
   - **Environment image:** Managed image
   - **Operating system:** Amazon Linux 2
   - **Runtime(s):** Standard
   - **Image:** aws/codebuild/amazonlinux2-x86_64-standard:3.0
   - **Image version:** Always use the latest image for this runtime version
   - **Environment type:** Linux
   - **Service role:** Create new service role (or use existing if available)

5. **Buildspec Configuration:**
   - **Build specifications:** Use a buildspec file
   - **Buildspec name:** Leave blank (will use `buildspec.yml` from root)
   - ⚠️ **Important:** The buildspec file is already included in your source code zip file

6. **Artifacts Configuration:**
   - **Type:** Amazon S3
   - **Bucket name:** Use the output bucket name from `bucket-names.txt`
   - **Name:** `codebuild-demo-output.zip`
   - **Artifacts packaging:** Zip
   - **Additional configuration:** Leave defaults

7. **Logs Configuration (Optional):**
   - **CloudWatch Logs:** Enabled (recommended for monitoring)
   - **Group name:** Leave default
   - **Stream name:** Leave default

8. **Click "Create build project"**

### Step 5: Run Build and Monitor (1 minute)

**Start the build in the console, then optionally monitor via terminal:**

```bash
# Optional: Monitor build progress from command line
./monitor-build.sh
```

**What the monitoring script does:**
- Checks if the CodeBuild project exists
- Finds the latest build for the project
- Continuously monitors build status
- Shows build details when complete

**Manual monitoring:**
- Watch the build phases in the AWS Console
- Observe the buildspec phases: install, pre_build, build, post_build

### Step 6: Verify Results (30 seconds)

**Run the artifact verification script:**
```bash
./verify-artifacts.sh
```

**What this script does:**
- Lists contents of the output S3 bucket
- Downloads the build artifacts
- Extracts and examines the contents
- Shows details of the generated JAR file

### Step 7: Cleanup (30 seconds)

**Run the cleanup script:**
```bash
./cleanup.sh
```

**What this script does:**
- Prompts for confirmation
- Deletes S3 buckets and their contents
- Removes the CodeBuild project
- Cleans up all local files and directories

## Script Details

### Individual Script Usage

**Setup Project:**
```bash
./setup-project.sh
# Creates project structure and copies files
```

**Show BuildSpec Contents:**
```bash
./show-buildspec.sh
# Displays buildspec.yml contents and explanation (helpful during console setup)
```

**Create S3 Buckets:**
```bash
./create-s3-buckets.sh
# Creates unique S3 buckets and saves names
```

**Upload Source:**
```bash
./upload-source.sh
# Packages and uploads source code to S3
```

**Monitor Build:**
```bash
./monitor-build.sh
# Monitors CodeBuild project status in real-time
```

**Verify Artifacts:**
```bash
./verify-artifacts.sh
# Downloads and examines build artifacts
```

**Cleanup:**
```bash
./cleanup.sh
# Removes all AWS resources and local files
```

**Testing:**
```bash
./test-syntax.sh
# Validates syntax of all scripts and checks file integrity
```

```bash
./test-artifact-handling.sh
# Demonstrates the artifact download and processing logic
```

## Key Learning Points

- **Continuous Integration:** Automated building and testing of code changes
- **BuildSpec File:** Defines build commands and phases
- **Artifact Management:** Input from S3, output to S3
- **Build Monitoring:** Real-time logs and status tracking
- **Integration:** Console and CLI workflows
- **Automation:** Scripts reduce manual errors and save time

## Troubleshooting Tips

- **Permission Issues:** Ensure IAM roles have proper S3 and CodeBuild permissions
- **Script Errors:** Check that all scripts are executable (`chmod +x *.sh`)
- **Bucket Names:** Scripts generate unique names to avoid conflicts
- **Build Failures:** Check CloudWatch Logs for detailed error messages
- **Missing Files:** Ensure all source files are present before running scripts
- **BuildSpec Issues:** Run `./show-buildspec.sh` to review the build specification
- **Console Setup:** Make sure to select "Use a buildspec file" in CodeBuild console
- **Source Upload:** Verify the source zip contains buildspec.yml in the root directory

## Advanced Usage

**Custom Configuration:**
- Modify `buildspec.yml` to change build behavior
- Edit Java source files to test different scenarios
- Adjust `pom.xml` for different dependencies

**Integration Testing:**
- Add more test cases to `TestMessageUtil.java`
- Include integration tests in the build process
- Add code quality checks (e.g., SpotBugs, Checkstyle)

## File Contents

### buildspec.yml
The build specification defines the build phases:
- **install:** Sets up Java runtime
- **pre_build:** Compiles the code
- **build:** Runs tests
- **post_build:** Packages the JAR file

### MessageUtil.java
Simple utility class demonstrating:
- Constructor pattern
- Method implementation
- String manipulation

### TestMessageUtil.java
JUnit test class demonstrating:
- Unit test structure
- Assertion usage
- Test method organization

## Citations

1. [Getting started with CodeBuild - AWS CodeBuild](https://docs.aws.amazon.com/codebuild/latest/userguide/getting-started-overview.html)
2. [AWS CodeBuild concepts - AWS CodeBuild](https://docs.aws.amazon.com/codebuild/latest/userguide/concepts.html)
3. [What is AWS CodeBuild? - AWS CodeBuild](https://docs.aws.amazon.com/codebuild/latest/userguide/welcome.html)
4. [Continuous integration - DevOps Guidance](https://docs.aws.amazon.com/wellarchitected/latest/devops-guidance/continuous-integration.html)
5. [Build specification reference for CodeBuild - AWS CodeBuild](https://docs.aws.amazon.com/codebuild/latest/userguide/build-spec-ref.html)
