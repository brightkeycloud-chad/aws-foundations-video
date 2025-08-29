exports.handler = async (event) => {
    return {
        statusCode: 200,
        body: JSON.stringify({
            message: 'Hello World from Lambda v1!',
            version: '1.0.0',
            timestamp: new Date().toISOString()
        })
    };
};
