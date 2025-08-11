#!/bin/bash

# Script 3: Test the Bedrock Agent
echo "Testing Bedrock Agent..."

# Check if Python3 is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 is not installed. Please install Python3 to test the agent via CLI."
    echo "   You can still test the agent using the AWS Console."
    exit 1
fi

echo "✅ Python3 is available"

# Create virtual environment if it doesn't exist
VENV_DIR="bedrock-agent-venv"
if [ ! -d "$VENV_DIR" ]; then
    echo "🔧 Creating Python virtual environment..."
    python3 -m venv $VENV_DIR
    if [ $? -ne 0 ]; then
        echo "❌ Failed to create virtual environment. Please ensure python3-venv is installed."
        echo "   On Ubuntu/Debian: sudo apt install python3-venv"
        echo "   On macOS: Virtual environments should work by default"
        exit 1
    fi
    echo "✅ Virtual environment created: $VENV_DIR"
else
    echo "✅ Virtual environment already exists: $VENV_DIR"
fi

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source $VENV_DIR/bin/activate

# Check if boto3 is installed in the virtual environment
if ! python -c "import boto3" 2>/dev/null; then
    echo "📦 Installing boto3 in virtual environment..."
    pip install boto3
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install boto3 in virtual environment."
        echo "   You can still test the agent using the AWS Console."
        deactivate
        exit 1
    fi
    echo "✅ boto3 installed successfully in virtual environment"
else
    echo "✅ boto3 is already available in virtual environment"
fi

# Get agent ID from AWS
echo "Looking up agent ID..."
AGENT_ID=$(aws bedrock-agent list-agents --query 'agentSummaries[?agentName==`WeatherAgent`].agentId' --output text)

if [ -z "$AGENT_ID" ] || [ "$AGENT_ID" == "None" ]; then
    echo "❌ WeatherAgent not found. Please create the agent via the AWS Console first."
    echo "   Follow Step 3 in the README to create the agent using the console."
    deactivate
    exit 1
fi

echo "✅ Found WeatherAgent with ID: $AGENT_ID"

# Create Python script to test the agent
cat > test_agent.py << EOF
import boto3
import json
import uuid
from datetime import datetime
import sys

def test_bedrock_agent():
    print("🔧 Initializing Bedrock Agent Runtime client...")
    
    try:
        # Initialize the Bedrock Agent Runtime client
        client = boto3.client('bedrock-agent-runtime')
        print("✅ Bedrock client initialized successfully")
    except Exception as e:
        print(f"❌ Failed to initialize Bedrock client: {str(e)}")
        print("   Please ensure AWS credentials are configured properly.")
        return []
    
    agent_id = '$AGENT_ID'
    agent_alias_id = 'TSTALIASID'  # Test alias ID
    
    # Test queries
    test_queries = [
        {
            'query': "What's the weather like in Seattle?",
            'file': 'response-seattle.json',
            'emoji': '🌧️'
        },
        {
            'query': "Can you tell me the current weather in New York?",
            'file': 'response-newyork.json',
            'emoji': '🌞'
        },
        {
            'query': "How's the weather in Miami today?",
            'file': 'response-miami.json',
            'emoji': '🌤️'
        }
    ]
    
    results = []
    
    for i, test in enumerate(test_queries, 1):
        print(f"\n{test['emoji']} Test {i}: {test['query']}")
        
        try:
            # Generate unique session ID for each test
            session_id = str(uuid.uuid4())
            
            print(f"   📡 Invoking agent with session ID: {session_id[:8]}...")
            
            # Invoke the agent
            response = client.invoke_agent(
                agentId=agent_id,
                agentAliasId=agent_alias_id,
                sessionId=session_id,
                inputText=test['query']
            )
            
            print(f"   📥 Processing streaming response...")
            
            # Process the streaming response
            full_response = ""
            chunk_count = 0
            
            for event in response['completion']:
                if 'chunk' in event:
                    chunk = event['chunk']
                    if 'bytes' in chunk:
                        chunk_text = chunk['bytes'].decode('utf-8')
                        full_response += chunk_text
                        chunk_count += 1
            
            print(f"   📊 Received {chunk_count} response chunks")
            
            # Save response to file
            response_data = {
                'query': test['query'],
                'response': full_response,
                'timestamp': datetime.now().isoformat(),
                'agent_id': agent_id,
                'session_id': session_id,
                'chunk_count': chunk_count
            }
            
            with open(test['file'], 'w') as f:
                json.dump(response_data, f, indent=2)
            
            print(f"   ✅ Query successful - Response saved to {test['file']}")
            results.append({
                'success': True, 
                'file': test['file'], 
                'response': full_response[:100] + "..." if len(full_response) > 100 else full_response,
                'length': len(full_response)
            })
            
        except Exception as e:
            print(f"   ❌ Query failed: {str(e)}")
            results.append({'success': False, 'error': str(e)})
    
    return results

if __name__ == "__main__":
    print("🐍 Testing Bedrock Agent with Python boto3...")
    print(f"🔧 Using Python: {sys.executable}")
    print(f"🔧 boto3 version: {boto3.__version__}")
    
    results = test_bedrock_agent()
    
    print("\n📊 Test Results Summary:")
    print("=" * 50)
    
    success_count = 0
    for i, result in enumerate(results, 1):
        if result['success']:
            success_count += 1
            print(f"Test {i}: ✅ Success ({result['length']} characters)")
            print(f"         Preview: {result['response']}")
        else:
            print(f"Test {i}: ❌ Failed - {result['error']}")
        print()
    
    print(f"🎯 Results: {success_count}/{len(results)} tests passed")
    print("🎉 Agent testing completed!")
    print("💡 Tip: Check the generated JSON files for full responses.")
EOF

echo ""
echo "🐍 Running Python test script in virtual environment..."
python test_agent.py

# Store the exit code
TEST_EXIT_CODE=$?

# Check if test was successful
if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo ""
    echo "📄 Generated Response Files:"
    echo "============================"
    
    if [ -f "response-seattle.json" ]; then
        echo "📁 response-seattle.json"
        echo "   Preview: $(python -c "import json; data=json.load(open('response-seattle.json')); print(data['response'][:100] + '...' if len(data['response']) > 100 else data['response'])" 2>/dev/null || echo "Could not read file")"
        echo ""
    fi
    
    if [ -f "response-newyork.json" ]; then
        echo "📁 response-newyork.json"
        echo "   Preview: $(python -c "import json; data=json.load(open('response-newyork.json')); print(data['response'][:100] + '...' if len(data['response']) > 100 else data['response'])" 2>/dev/null || echo "Could not read file")"
        echo ""
    fi
    
    if [ -f "response-miami.json" ]; then
        echo "📁 response-miami.json"
        echo "   Preview: $(python -c "import json; data=json.load(open('response-miami.json')); print(data['response'][:100] + '...' if len(data['response']) > 100 else data['response'])" 2>/dev/null || echo "Could not read file")"
        echo ""
    fi
else
    echo ""
    echo "⚠️  Python test failed. You can still test the agent manually:"
    echo "   1. Go to AWS Console → Amazon Bedrock → Agents"
    echo "   2. Select your WeatherAgent"
    echo "   3. Click 'Test Agent'"
    echo "   4. Try queries like 'What's the weather in Seattle?'"
fi

# Deactivate virtual environment
echo "🔧 Deactivating virtual environment..."
deactivate

# Clean up the temporary Python script
rm -f test_agent.py

echo ""
echo "🎯 Testing completed!"
echo "💡 Virtual environment preserved at: $VENV_DIR"
echo "   (Will be cleaned up when you run cleanup.sh)"
