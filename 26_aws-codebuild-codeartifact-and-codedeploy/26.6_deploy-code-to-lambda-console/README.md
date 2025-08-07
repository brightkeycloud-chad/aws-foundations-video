# Deploy Code to AWS Lambda Console - 5-Minute Demonstration

## Overview
This demonstration shows how to create, deploy, and test a Lambda function using the AWS Console. The demonstration takes approximately 5 minutes and covers the complete workflow from function creation to testing and cleanup.

## Prerequisites
- AWS Account with appropriate permissions
- Access to AWS Management Console
- Basic understanding of JSON format

## Demonstration Steps

### Step 1: Access Lambda Console (30 seconds)
1. Sign in to the [AWS Management Console](https://console.aws.amazon.com/)
2. Navigate to the [Lambda Functions page](https://console.aws.amazon.com/lambda/home#/functions)
3. Click **Create function**

### Step 2: Create Lambda Function (1 minute)
1. Select **Author from scratch**
2. Configure basic information:
   - **Function name**: `myLambdaFunction`
   - **Runtime**: Choose **Python 3.13** or **Node.js 22**
   - **Architecture**: Leave as **x86_64**
3. Click **Create function**

*Note: Lambda automatically creates an execution role with basic CloudWatch Logs permissions*

### Step 3: Deploy Function Code (2 minutes)

#### For Python Runtime:
1. Click the **Code** tab
2. Select **lambda_function.py** in the file explorer
3. Replace the default code with:

```python
import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    
    # Get the length and width parameters from the event object
    length = event['length']
    width = event['width']
    
    area = calculate_area(length, width)
    print(f"The area is {area}")
        
    logger.info(f"CloudWatch logs group: {context.log_group_name}")
    
    # return the calculated area as a JSON string
    data = {"area": area}
    return json.dumps(data)
    
def calculate_area(length, width):
    return length*width
```

#### For Node.js Runtime:
1. Click the **Code** tab
2. Select **index.mjs** in the file explorer
3. Replace the default code with:

```javascript
export const handler = async (event, context) => {
  
  const length = event.length;
  const width = event.width;
  let area = calculateArea(length, width);
  console.log(`The area is ${area}`);
        
  console.log('CloudWatch log group: ', context.logGroupName);
  
  let data = {
    "area": area,
  };
    return JSON.stringify(data);
    
  function calculateArea(length, width) {
    return length * width;
  }
};
```

4. Click **Deploy** to update the function code

### Step 4: Create and Run Test Event (1 minute)
1. In the **TEST EVENTS** section, click **Create test event**
2. Configure the test event:
   - **Event Name**: `myTestEvent`
   - **Event JSON**: Replace default JSON with:
   ```json
   {
     "length": 6,
     "width": 7
   }
   ```
3. Click **Save**
4. Click the **Run** icon next to your test event

### Step 5: Review Results (30 seconds)
1. Check the **OUTPUT** tab for:
   - **Status**: Should show "Succeeded"
   - **Response**: Should show `{"area":42}`
   - **Function Logs**: Should display calculated area and CloudWatch log group name

Expected output format:
```
Status: Succeeded
Test Event Name: myTestEvent

Response
"{\"area\":42}"

Function Logs
START RequestId: [request-id] Version: $LATEST
The area is 42
[INFO] CloudWatch logs group: /aws/lambda/myLambdaFunction
END RequestId: [request-id]
REPORT RequestId: [request-id] Duration: [time] ms...
```

### Step 6: View CloudWatch Logs (Optional - 30 seconds)
1. Open [CloudWatch Log groups](https://console.aws.amazon.com/cloudwatch/home#logs:)
2. Click on `/aws/lambda/myLambdaFunction`
3. Select the most recent log stream to view detailed execution logs

### Step 7: Cleanup (30 seconds)
1. Return to [Lambda Functions page](https://console.aws.amazon.com/lambda/home#/functions)
2. Select your function
3. Click **Actions** → **Delete**
4. Type `confirm` and click **Delete**

## Key Learning Points

### Lambda Handler Function
- **Python**: `lambda_handler(event, context)` is the entry point
- **Node.js**: `handler` function is the entry point
- The handler name must match the runtime configuration

### Event Object
- Contains input data for your function
- In this demo: JSON with `length` and `width` properties
- Lambda converts JSON to native objects (dict in Python, object in Node.js)

### Context Object
- Provides runtime information about the function execution
- Includes log group name, request ID, and other metadata
- Used for monitoring and debugging purposes

### Logging
- **Python**: Use `print()` statements or logging library
- **Node.js**: Use `console.log()` methods
- All logs are automatically sent to CloudWatch Logs

## Troubleshooting

### Common Issues:
1. **Function fails to run**: Check that handler name matches the function name
2. **Missing event properties**: Ensure test event JSON includes required `length` and `width` fields
3. **Permission errors**: Verify your AWS account has Lambda execution permissions

### Error Messages:
- `"errorType": "KeyError"` (Python) or `TypeError` (Node.js): Missing required event properties
- `"errorType": "Runtime.HandlerNotFound"`: Handler function name mismatch

## Additional Resources

### AWS Documentation References:
- [Create your first Lambda function](https://docs.aws.amazon.com/lambda/latest/dg/getting-started.html) - Complete getting started guide
- [Testing Lambda functions in the console](https://docs.aws.amazon.com/lambda/latest/dg/testing-functions.html) - Detailed testing procedures
- [Define Lambda function handler in Python](https://docs.aws.amazon.com/lambda/latest/dg/python-handler.html) - Python-specific handler documentation
- [Define Lambda function handler in Node.js](https://docs.aws.amazon.com/lambda/latest/dg/nodejs-handler.html) - Node.js-specific handler documentation

### Next Steps:
- Learn about [Lambda deployment packages](https://docs.aws.amazon.com/lambda/latest/dg/python-package.html)
- Explore [Lambda triggers with other AWS services](https://docs.aws.amazon.com/lambda/latest/dg/with-s3-example.html)
- Understand [Lambda execution roles and permissions](https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html)

---

*This demonstration is based on AWS Lambda documentation current as of August 2025. For the most up-to-date information, always refer to the official AWS documentation.*
