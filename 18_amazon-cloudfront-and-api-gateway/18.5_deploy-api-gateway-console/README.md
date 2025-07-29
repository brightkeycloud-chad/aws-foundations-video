# Deploy API Gateway - Console Demonstration

## Overview
This 5-minute demonstration shows how to create and deploy a REST API using Amazon API Gateway through the AWS Management Console. You'll build a serverless API that integrates with AWS Lambda to handle HTTP requests.

## Prerequisites
- AWS account with appropriate permissions
- Basic understanding of REST APIs and HTTP methods
- Access to AWS Management Console

## Demonstration Objectives
By the end of this demonstration, you will:
- Create a Lambda function for API backend
- Build a REST API using API Gateway console
- Configure Lambda proxy integration
- Deploy and test the API

## Step-by-Step Instructions

### Step 1: Create Lambda Function (1.5 minutes)
1. **Access Lambda Console**:
   - Navigate to https://console.aws.amazon.com/lambda
   - Click **Create function**

2. **Configure Function**:
   - Under **Basic information**, enter function name: `my-api-function`
   - Keep **Runtime** as **Node.js** (latest version)
   - Leave other settings as default
   - Click **Create function**

3. **Update Function Code**:
   - Replace the default code with:
   ```javascript
   export const handler = async (event) => {
       const response = {
           statusCode: 200,
           headers: {
               "Content-Type": "application/json"
           },
           body: JSON.stringify({
               message: 'Hello from API Gateway and Lambda!',
               timestamp: new Date().toISOString(),
               method: event.httpMethod,
               path: event.path
           }),
       };
       return response;
   };
   ```
   - Click **Deploy** to save changes

### Step 2: Create REST API (1.5 minutes)
1. **Access API Gateway Console**:
   - Navigate to https://console.aws.amazon.com/apigateway
   - For **REST API**, click **Build**

2. **Configure API**:
   - **API name**: `my-demo-api`
   - **Description**: `Demo REST API for training`
   - **API endpoint type**: **Regional**
   - **IP address type**: **IPv4**
   - Click **Create API**

### Step 3: Create Method and Integration (1.5 minutes)
1. **Create Method**:
   - Select the root resource (`/`)
   - Click **Create method**
   - **Method type**: Select `ANY` (handles all HTTP methods)
   - **Integration type**: Select **Lambda**
   - Turn on **Lambda proxy integration**
   - **Lambda function**: Enter `my-api-function` and select your function
   - Click **Create method**

2. **Review Integration**:
   - Notice the method execution flow diagram
   - The `ANY` method will handle GET, POST, PUT, DELETE, etc.

### Step 4: Deploy and Test API (0.5 minutes)
1. **Deploy API**:
   - Click **Deploy API**
   - **Stage**: Select **New stage**
   - **Stage name**: `prod`
   - **Description**: `Production stage`
   - Click **Deploy**

2. **Get Invoke URL**:
   - Navigate to **Stages** in the left panel
   - Click on **prod** stage
   - Copy the **Invoke URL** (e.g., `https://abcd123.execute-api.us-east-1.amazonaws.com/prod`)

3. **Test the API**:
   - Open a new browser tab
   - Paste the invoke URL
   - You should see a JSON response with your message

### Step 5: Advanced Testing (Optional - if time permits)
1. **Test Different Methods**:
   - Use browser developer tools or a tool like curl
   - Try: `curl -X POST [your-invoke-url]`
   - Notice how the Lambda function receives different HTTP methods

2. **View Logs**:
   - Go back to Lambda console
   - Click on **Monitor** tab
   - Click **View CloudWatch logs** to see execution logs

## Key Points to Highlight During Demo
- **Serverless Architecture**: No servers to manage, pay per request
- **Lambda Proxy Integration**: API Gateway passes entire request to Lambda
- **Automatic Scaling**: Handles traffic spikes automatically
- **Multiple HTTP Methods**: Single `ANY` method handles all HTTP verbs
- **Stage Management**: Separate environments (dev, test, prod)
- **Monitoring**: Built-in CloudWatch integration for logs and metrics

## API Response Format
The Lambda function returns responses in API Gateway's required format:
```json
{
    "statusCode": 200,
    "headers": {
        "Content-Type": "application/json"
    },
    "body": "{\"message\":\"Hello from API Gateway and Lambda!\"}"
}
```

## Common Issues and Troubleshooting
- **502 Bad Gateway**: Check Lambda function response format
- **403 Forbidden**: Verify API Gateway has permission to invoke Lambda
- **Function Not Found**: Ensure Lambda function name matches exactly
- **CORS Issues**: Add CORS headers if calling from web browsers

## Cleanup Instructions
To avoid ongoing charges:
1. **Delete API Gateway**:
   - In API Gateway console, select your API
   - Click **Actions** → **Delete API**
   - Type "confirm" and click **Delete**

2. **Delete Lambda Function**:
   - In Lambda console, select your function
   - Click **Actions** → **Delete**
   - Type "delete" and confirm

3. **Delete CloudWatch Logs** (Optional):
   - Navigate to CloudWatch console
   - Delete log group `/aws/lambda/my-api-function`

## Testing Commands
```bash
# Test GET request
curl https://your-api-url.execute-api.region.amazonaws.com/prod

# Test POST request
curl -X POST https://your-api-url.execute-api.region.amazonaws.com/prod

# Test with data
curl -X POST -H "Content-Type: application/json" \
  -d '{"name":"test"}' \
  https://your-api-url.execute-api.region.amazonaws.com/prod
```

## Additional Resources and Citations

### AWS Documentation References
- [Get started with the REST API console - Amazon API Gateway](https://docs.aws.amazon.com/apigateway/latest/developerguide/getting-started-rest-new-console.html)
- [Set up Lambda proxy integrations in API Gateway](https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html)
- [Deploy a REST API in Amazon API Gateway](https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-deploy-api.html)

### Additional Learning
- [API Gateway Pricing](https://aws.amazon.com/api-gateway/pricing/)
- [API Gateway Best Practices](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-basic-concept.html)
- [Lambda Function Handler](https://docs.aws.amazon.com/lambda/latest/dg/nodejs-handler.html)
- [API Gateway Request/Response Data Mapping](https://docs.aws.amazon.com/apigateway/latest/developerguide/request-response-data-mappings.html)

---
*Last updated: July 2025*
*Documentation sources: AWS Official Documentation*
