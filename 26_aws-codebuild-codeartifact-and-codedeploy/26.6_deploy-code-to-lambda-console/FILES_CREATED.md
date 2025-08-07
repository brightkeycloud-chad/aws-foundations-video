# Deploy Code to AWS Lambda Console - Files Created

This directory contains all the files needed for the 5-minute Lambda demonstration.

## Main Documentation
- **README.md** - Complete demonstration instructions with step-by-step guide
- **DEMONSTRATION_SCRIPT.md** - Detailed script for presenters with timing and talking points

## Sample Code Files
- **lambda_function.py** - Python version of the Lambda function
- **index.mjs** - Node.js version of the Lambda function  
- **test_event.json** - Sample test event JSON for the demonstration

## Testing and Validation
- **test_lambda_demo.py** - Python script to programmatically validate the instructions
- **run_test.sh** - Bash script to run the validation test

## Cleanup Scripts
- **quick_cleanup.sh** - Fast AWS CLI-based cleanup script (recommended)
- **cleanup.py** - Comprehensive Python cleanup script with resource discovery
- **cleanup.sh** - Bash wrapper for the Python cleanup script
- **CLEANUP_README.md** - Documentation for all cleanup scripts

## Documentation
- **FILES_CREATED.md** - This summary file
- **VALIDATION_REPORT.md** - Test results and validation documentation

## How to Use These Files

### For Demonstration:
1. Follow the **README.md** instructions step-by-step
2. Use **DEMONSTRATION_SCRIPT.md** for presentation timing and talking points
3. Copy code from **lambda_function.py** or **index.mjs** as needed
4. Use **test_event.json** content for the test event

### For Validation:
1. Run `./run_test.sh` to validate that the instructions work
2. The test script will create, test, and clean up Lambda functions automatically
3. Both Python and Node.js runtimes are tested

### For Cleanup:
1. Run `./quick_cleanup.sh` for fast cleanup using AWS CLI
2. Run `./cleanup.sh` for comprehensive cleanup with resource discovery
3. See **CLEANUP_README.md** for detailed cleanup documentation

## Documentation Sources
All instructions are based on the latest AWS Lambda documentation:
- [Create your first Lambda function](https://docs.aws.amazon.com/lambda/latest/dg/getting-started.html)
- [Testing Lambda functions in the console](https://docs.aws.amazon.com/lambda/latest/dg/testing-functions.html)
- [Define Lambda function handler in Python](https://docs.aws.amazon.com/lambda/latest/dg/python-handler.html)
- [Define Lambda function handler in Node.js](https://docs.aws.amazon.com/lambda/latest/dg/nodejs-handler.html)

## Prerequisites
- AWS Account with Lambda permissions
- AWS CLI configured (for testing script)
- Python 3 and boto3 (for testing script)
- Basic understanding of JSON format

## Demonstration Timeline
- **Total Time**: 5 minutes
- **Setup**: 30 seconds
- **Function Creation**: 1 minute
- **Code Deployment**: 2 minutes
- **Testing**: 1 minute
- **Results Review**: 30 seconds
- **Cleanup**: 30 seconds

The demonstration successfully shows the complete workflow from Lambda function creation to testing and cleanup using the AWS Console.
