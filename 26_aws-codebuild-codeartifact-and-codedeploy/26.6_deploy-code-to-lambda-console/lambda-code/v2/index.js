exports.handler = async (event) => {
    return {
        statusCode: 200,
        body: JSON.stringify({
            message: 'Hello from CodeDeploy! Lambda v2 deployed successfully!',
            version: '2.0.0',
            timestamp: new Date().toISOString(),
            deployedVia: 'AWS CodeDeploy'
        })
    };
};
