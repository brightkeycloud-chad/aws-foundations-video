# Lambda Console Deployment - 5-Minute Demonstration Script

## Pre-Demonstration Setup (Before Starting)
- [ ] Open AWS Management Console in browser
- [ ] Have this script and README.md open for reference
- [ ] Ensure you're in a region that supports Lambda (e.g., us-east-1, us-west-2)
- [ ] Clear any existing Lambda functions named `myLambdaFunction`

## Demonstration Timeline (5 minutes total)

### **Minute 1: Introduction and Setup (0:00-1:00)**

**Say:** "Today I'll show you how to deploy code to AWS Lambda using the console. This is a fundamental skill for serverless development. We'll create a simple function that calculates area, test it, and clean up - all in 5 minutes."

**Actions:**
1. Navigate to AWS Lambda console: https://console.aws.amazon.com/lambda/home#/functions
2. Click **Create function**
3. Select **Author from scratch**

**Say:** "Lambda offers several creation options, but 'Author from scratch' gives us the most control for learning."

### **Minute 2: Function Configuration (1:00-2:00)**

**Actions:**
1. Enter function name: `myLambdaFunction`
2. Select runtime: **Python 3.13** (or Node.js 22 if preferred)
3. Leave architecture as **x86_64**
4. Click **Create function**

**Say:** "Lambda automatically creates an execution role with CloudWatch Logs permissions. This is one of Lambda's conveniences - it handles the IAM complexity for basic scenarios."

**Wait for function creation to complete**

### **Minute 3: Code Deployment (2:00-3:00)**

**Actions:**
1. Click the **Code** tab
2. Select **lambda_function.py** in the file explorer
3. Replace default code with the Python code from README.md:

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

4. Click **Deploy**

**Say:** "Notice the handler function signature - event contains our input data, context provides runtime information. The console's built-in editor makes code changes simple for development and testing."

### **Minute 4: Testing (3:00-4:00)**

**Actions:**
1. In **TEST EVENTS** section, click **Create test event**
2. Enter event name: `myTestEvent`
3. Replace default JSON with:
```json
{
  "length": 6,
  "width": 7
}
```
4. Click **Save**
5. Click the **Run** icon next to the test event

**Say:** "Test events simulate how your function receives data. In production, this might come from API Gateway, S3 events, or other AWS services."

### **Minute 5: Results and Cleanup (4:00-5:00)**

**Actions:**
1. Review the **OUTPUT** tab:
   - Point out "Status: Succeeded"
   - Show response: `{"area":42}`
   - Highlight function logs showing calculated area and CloudWatch log group

**Say:** "Perfect! Our function calculated 6 × 7 = 42. The logs show both our print statement and the logger output, demonstrating different logging approaches."

**Optional (if time permits):**
2. Briefly show CloudWatch Logs:
   - Navigate to CloudWatch → Log groups
   - Click `/aws/lambda/myLambdaFunction`
   - Show the log stream

**Cleanup:**
3. Return to Lambda console
4. Select the function
5. Click **Actions** → **Delete**
6. Type `confirm` and click **Delete**

**Say:** "And that's it! In 5 minutes, we've created, deployed, tested, and cleaned up a Lambda function. This workflow scales from simple functions like this to complex serverless applications."

## Key Points to Emphasize

### During Code Explanation:
- **Handler Function**: Entry point that Lambda calls
- **Event Object**: Contains input data (JSON becomes Python dict/JS object)
- **Context Object**: Runtime metadata for monitoring
- **Return Value**: Must be JSON-serializable

### During Testing:
- **Test Events**: Simulate real-world triggers
- **Synchronous Invocation**: Immediate response for testing
- **CloudWatch Integration**: Automatic log collection

### Best Practices Mentioned:
- Use logging for debugging and monitoring
- Test functions thoroughly before production
- Clean up resources to avoid charges
- Understand the handler signature for your runtime

## Troubleshooting During Demo

### If Function Creation Fails:
- Check IAM permissions
- Verify region supports Lambda
- Ensure function name is unique

### If Code Deployment Fails:
- Verify syntax (Python indentation, JS brackets)
- Check that handler name matches configuration
- Ensure all required imports are present

### If Test Fails:
- Verify test event JSON syntax
- Check that event contains required fields (`length`, `width`)
- Review function logs for error details

## Post-Demonstration Q&A Preparation

**Common Questions:**
1. **"How do I add external libraries?"** → Deployment packages and layers
2. **"What about environment variables?"** → Configuration tab
3. **"How do I connect to other AWS services?"** → IAM roles and SDK
4. **"What are the cost implications?"** → Pay-per-request pricing model
5. **"How do I deploy in production?"** → Infrastructure as Code, CI/CD pipelines

## Additional Demo Variations

### For Advanced Audiences:
- Show environment variables configuration
- Demonstrate error handling with invalid input
- Explain execution role permissions in detail

### For Beginner Audiences:
- Spend more time explaining serverless concepts
- Show the AWS Lambda pricing calculator
- Emphasize the "no server management" benefits

---

**Total Time: 5 minutes**
**Preparation Time: 2 minutes**
**Cleanup Time: 30 seconds**
