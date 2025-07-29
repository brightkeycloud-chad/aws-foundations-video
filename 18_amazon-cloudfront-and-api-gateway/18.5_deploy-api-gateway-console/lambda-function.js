// Lambda function code for API Gateway demonstration
// Copy this code into the Lambda function editor during the demo

export const handler = async (event) => {
    console.log('Event received:', JSON.stringify(event, null, 2));
    
    // Extract information from the API Gateway event
    const method = event.httpMethod;
    const path = event.path;
    const queryParams = event.queryStringParameters || {};
    const headers = event.headers || {};
    const body = event.body ? JSON.parse(event.body) : null;
    
    // Create response based on HTTP method
    let responseMessage;
    
    switch (method) {
        case 'GET':
            responseMessage = 'Hello! This is a GET request response.';
            break;
        case 'POST':
            responseMessage = 'Data received via POST request.';
            break;
        case 'PUT':
            responseMessage = 'Resource updated via PUT request.';
            break;
        case 'DELETE':
            responseMessage = 'Resource deleted via DELETE request.';
            break;
        default:
            responseMessage = `Request received via ${method} method.`;
    }
    
    // Prepare the response
    const response = {
        statusCode: 200,
        headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*", // Enable CORS for web browsers
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS"
        },
        body: JSON.stringify({
            message: responseMessage,
            details: {
                timestamp: new Date().toISOString(),
                method: method,
                path: path,
                queryParameters: queryParams,
                userAgent: headers['User-Agent'] || 'Unknown',
                sourceIP: event.requestContext?.identity?.sourceIp || 'Unknown'
            },
            requestBody: body,
            apiGatewayInfo: {
                requestId: event.requestContext?.requestId,
                stage: event.requestContext?.stage,
                resourcePath: event.resource
            }
        }, null, 2),
    };
    
    return response;
};
