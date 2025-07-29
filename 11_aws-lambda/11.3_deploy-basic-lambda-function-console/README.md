# Deploy Basic Lambda Function (Console)

## Demonstration Overview
**Duration:** 5 minutes  
**Tools:** AWS Management Console  
**Objective:** Create and deploy a basic Lambda function using the AWS Console's built-in code editor

This demonstration shows how to create your first Lambda function using the AWS Management Console, test it with sample data, and view execution logs in CloudWatch.

## Prerequisites
- AWS account with appropriate permissions
- Access to AWS Management Console
- Basic understanding of JSON format

## Step-by-Step Instructions

### Step 1: Create the Lambda Function (2 minutes)

1. **Navigate to Lambda Console**
   - Open the [AWS Lambda Console](https://console.aws.amazon.com/lambda/)
   - Click **Create function**

2. **Configure Basic Information**
   - Select **Author from scratch**
   - Function name: `AreaCalculatorFunction`
   - Runtime: **Python 3.13** (or latest available)
   - Architecture: **x86_64**
   - Click **Create function**

3. **Review Auto-Generated Components**
   - Note the execution role created automatically
   - Observe the basic "Hello from Lambda!" code template

### Step 2: Implement Function Code (1.5 minutes)

1. **Access Code Editor**
   - Click the **Code** tab
   - Select **lambda_function.py** in the file explorer

2. **Replace Default Code**
   - Delete the existing code
   - Copy and paste the code from `lambda_function.py` in this directory
   - Click **Deploy** to save changes

3. **Review Code Features**
   - Event parameter extraction
   - Input validation
   - Error handling
   - Logging implementation
   - JSON response formatting

### Step 3: Test the Function (1 minute)

1. **Create Test Event**
   - Click **Test** button
   - Select **Create new event**
   - Event name: `AreaTest`
   - Replace the default JSON with:
   ```json
   {
     "length": 10,
     "width": 5
   }
   ```
   - Click **Save**

2. **Execute Test**
   - Click **Test** to run the function
   - Review the execution result
   - Note the calculated area (50 square units)

### Step 4: View Logs and Monitor (30 seconds)

1. **Check Execution Results**
   - Expand the **Execution result** section
   - Review the response body and status code
   - Note the execution duration and memory usage

2. **Access CloudWatch Logs**
   - Click **Monitor** tab
   - Click **View CloudWatch logs**
   - Examine the log entries showing:
     - Received event data
     - Calculated area
     - Function execution details

## Key Learning Points

- **Event-Driven Architecture**: Lambda functions respond to events containing input data
- **Execution Context**: Functions receive `event` and `context` parameters
- **Built-in Logging**: CloudWatch Logs automatically capture function output
- **Error Handling**: Proper exception handling returns meaningful error responses
- **JSON Communication**: Input and output use JSON format for data exchange

## Testing Variations

Try these additional test cases to explore function behavior:

**Valid Input:**
```json
{
  "length": 7.5,
  "width": 4.2
}
```

**Invalid Input (triggers error handling):**
```json
{
  "length": -5,
  "width": 10
}
```

**Missing Parameters:**
```json
{
  "length": 8
}
```

## Expected Outcomes

- Successfully created Lambda function using console
- Function correctly calculates area from length and width
- Proper error handling for invalid inputs
- CloudWatch logs capture execution details
- Understanding of basic Lambda concepts and event structure

## Cleanup

To avoid charges:
1. Delete the Lambda function: **Actions** → **Delete**
2. CloudWatch logs are automatically cleaned up

## Documentation References

- [Create your first Lambda function - AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/getting-started.html)
- [Define Lambda function handler in Python - AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/python-handler.html)
- [What is AWS Lambda? - AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html)
- [AWS Lambda execution context - AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/lambda-context.html)
