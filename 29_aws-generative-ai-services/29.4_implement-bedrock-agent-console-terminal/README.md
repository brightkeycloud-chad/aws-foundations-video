# Amazon Bedrock Agent Implementation Demo

## Overview
This 5-minute demonstration shows how to create and test an Amazon Bedrock Agent using both the AWS Console and terminal commands. The agent will be configured with a simple action group to demonstrate basic functionality.

## Prerequisites
- AWS CLI configured with appropriate permissions
- Access to Amazon Bedrock service
- IAM permissions for Bedrock agents and Lambda functions

## Quick Start
For a streamlined experience, use the provided scripts:

```bash
# Run all setup steps automatically
./run-all-setup.sh

# Or run individual steps:
./01-create-iam-role.sh
./02-create-lambda-function.sh
# (Then create agent via console)
./03a-prepare-agent.sh
./03b-add-lambda-permission.sh
./03-test-agent.sh
```

## Demo Steps (5 minutes)

### Step 1: Create IAM Role for Bedrock Agent (1 minute)

**Using the provided script:**
```bash
./01-create-iam-role.sh
```

**What the script does:**
- Creates a trust policy allowing Bedrock service to assume the role
- Creates `BedrockAgentRole` with the trust policy
- Attaches `AmazonBedrockFullAccess` policy to the role

**Manual alternative via Console:**
- Navigate to IAM → Roles → Create role
- Select "AWS service" → "Bedrock"
- Attach `AmazonBedrockFullAccess` policy
- Name the role `BedrockAgentRole`

### Step 2: Create Lambda Function for Action Group (1.5 minutes)

**Using the provided script:**
```bash
./02-create-lambda-function.sh
```

**What the script does:**
- Creates a Python Lambda function that simulates weather data
- Creates `lambda-execution-role` with basic execution permissions
- Deploys the function as `bedrock-agent-weather`
- Provides different weather responses for different cities

**The Lambda function includes:**
- Weather simulation for Seattle, New York, Miami, and Denver
- Error handling for unknown functions
- Proper JSON response formatting for Bedrock agents

### Step 3: Create Bedrock Agent via Console (1.5 minutes)

**Console Steps:**
1. Navigate to Amazon Bedrock → Agents → Create Agent
2. **Agent Configuration:**
   - Agent name: `WeatherAgent`
   - Description: `Demo agent for weather information`
   - Foundation model: `Claude 3 Haiku`
   - Agent resource role: Select `BedrockAgentRole`

3. **Add Action Group:**
   - Click "Add Action Group"
   - Name: `WeatherActions`
   - Description: `Get weather information`
   - Action group type: `Define with function details`
   - Lambda function: Select `bedrock-agent-weather`
   
4. **Function Details:**
   - Function name: `get_weather`
   - Description: `Get current weather for a location`
   - Parameters:
     - Name: `location`
     - Type: `string`
     - Required: `true`
     - Description: `The city or location to get weather for`

5. **Save and Create** the agent

### Step 3a: Prepare the Agent (30 seconds)

**Using the provided script:**
```bash
./03a-prepare-agent.sh
```

**What the script does:**
- Checks the current agent status
- Updates agent configuration with proper role ARN and instructions if needed
- Prepares the agent for use (builds the agent)
- Waits for preparation to complete
- Provides status updates during the process

**Important:** This step is required after creating the agent via console. The agent must be "PREPARED" before it can be invoked.

### Step 3b: Add Lambda Permission (15 seconds)

**Using the provided script:**
```bash
./03b-add-lambda-permission.sh
```

**What the script does:**
- Finds the WeatherAgent ID
- Adds a resource-based policy to the Lambda function
- Allows the Bedrock agent to invoke the Lambda function
- Handles cases where permission already exists

**Important:** This step is required for the agent to successfully invoke the Lambda function. Without this permission, you'll get access denied errors.

### Step 4: Test the Agent (1 minute)

**Using the provided script:**
```bash
./03-test-agent.sh
```

**What the script does:**
- Automatically finds your WeatherAgent
- Creates a Python virtual environment for clean dependency management
- Installs boto3 in the virtual environment (AWS CLI doesn't support streaming operations)
- Tests with multiple weather queries (Seattle, New York, Miami)
- Saves responses to JSON files for review
- Provides a summary of test results
- Preserves the virtual environment for future use

**Important Note:** The AWS CLI doesn't support the `InvokeAgent` operation because it's a streaming API. The test script automatically uses Python with boto3 to properly invoke the agent.

**Manual testing via Console:**
- Click "Test Agent" in the agent details page
- Try these test prompts:
  - "What's the weather like in Seattle?"
  - "Can you tell me the current weather in New York?"
  - "How's the weather in Miami today?"

**Manual testing via Python (if you prefer to write your own):**
```python
import boto3

client = boto3.client('bedrock-agent-runtime')
response = client.invoke_agent(
    agentId='YOUR_AGENT_ID',
    agentAliasId='TSTALIASID',
    sessionId='test-session-1',
    inputText="What's the weather in Denver?"
)

# Process streaming response
for event in response['completion']:
    if 'chunk' in event:
        chunk = event['chunk']
        if 'bytes' in chunk:
            print(chunk['bytes'].decode('utf-8'))
```

## Script Files Included

| Script | Purpose | Duration |
|--------|---------|----------|
| `run-all-setup.sh` | Runs all setup steps automatically | 2-3 min |
| `01-create-iam-role.sh` | Creates IAM role for Bedrock Agent | 30 sec |
| `02-create-lambda-function.sh` | Creates and deploys Lambda function | 1 min |
| `03a-prepare-agent.sh` | Prepares agent after console creation | 30 sec |
| `03b-add-lambda-permission.sh` | Adds Lambda permission for agent | 15 sec |
| `03-test-agent.sh` | Tests the agent with multiple queries | 30 sec |
| `cleanup.sh` | Removes all demo resources | 1 min |

## Expected Results
- Successfully created Bedrock agent with weather action group
- Agent responds to weather queries by invoking Lambda function
- Different cities return different simulated weather data
- Demonstrates integration between Bedrock agents and AWS Lambda

## Sample Agent Responses

The agent will provide responses like:
- **Seattle**: "Cloudy and 62°F with light rain"
- **New York**: "Sunny and 75°F with clear skies"  
- **Miami**: "Hot and 85°F with high humidity"
- **Denver**: "Partly cloudy and 68°F with mountain breeze"

## Troubleshooting

**Common Issues:**
- **IAM Role Issues**: Ensure roles have correct trust relationships
- **Lambda Function**: Verify function is in the same region as Bedrock agent
- **Agent Not Found**: Make sure agent creation via console completed successfully
- **Permission Errors**: Check CloudWatch logs for Lambda execution details
- **Python/boto3 Issues**: The test script requires Python3 and creates a virtual environment
- **Virtual Environment Issues**: Ensure python3-venv is installed (Ubuntu/Debian: `sudo apt install python3-venv`)
- **AWS CLI Limitation**: AWS CLI doesn't support streaming operations like `InvokeAgent`

**Debug Commands:**
```bash
# Check if roles exist
aws iam get-role --role-name BedrockAgentRole
aws iam get-role --role-name lambda-execution-role

# Check if Lambda function exists
aws lambda get-function --function-name bedrock-agent-weather

# List all agents
aws bedrock-agent list-agents

# Check Python and virtual environment
python3 --version
python3 -m venv --help

# Check virtual environment (if created)
ls -la bedrock-agent-venv/
source bedrock-agent-venv/bin/activate && python -c "import boto3; print('boto3 version:', boto3.__version__)" && deactivate
```

**Alternative Testing Methods:**
1. **AWS Console**: Most reliable method - use the built-in test interface
2. **Python Script**: Use the provided test script or write your own with boto3
3. **AWS SDK**: Use any AWS SDK that supports streaming (Java, .NET, etc.)
4. **Postman/curl**: Direct API calls to the Bedrock Agent Runtime endpoint

## Cleanup
When the demo is complete, run the cleanup script:
```bash
./cleanup.sh
```

This will remove all created resources including:
- Bedrock Agent and action groups
- Lambda function
- IAM roles and policies
- Local files

## Citations and Documentation

1. **Amazon Bedrock Agents User Guide**
   - https://docs.aws.amazon.com/bedrock/latest/userguide/agents.html

2. **Creating and Managing Bedrock Agents**
   - https://docs.aws.amazon.com/bedrock/latest/userguide/agents-create.html

3. **Bedrock Agent Action Groups**
   - https://docs.aws.amazon.com/bedrock/latest/userguide/agents-action-create.html

4. **AWS Lambda Developer Guide**
   - https://docs.aws.amazon.com/lambda/latest/dg/welcome.html

5. **IAM Roles for Bedrock**
   - https://docs.aws.amazon.com/bedrock/latest/userguide/security_iam_service-with-iam.html
