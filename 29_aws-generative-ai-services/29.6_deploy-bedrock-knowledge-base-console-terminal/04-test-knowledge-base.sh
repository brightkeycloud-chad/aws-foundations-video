#!/bin/bash

# Script 4: Test Knowledge Base
echo "Testing Bedrock Knowledge Base..."

# Check if Python3 is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 is not installed. Please install Python3 to test the knowledge base via CLI."
    echo "   You can still test the knowledge base using the AWS Console."
    exit 1
fi

echo "✅ Python3 is available"

# Create virtual environment if it doesn't exist
VENV_DIR="bedrock-kb-venv"
if [ ! -d "$VENV_DIR" ]; then
    echo "🔧 Creating Python virtual environment..."
    python3 -m venv $VENV_DIR
    if [ $? -ne 0 ]; then
        echo "❌ Failed to create virtual environment. Please ensure python3-venv is installed."
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
        deactivate
        exit 1
    fi
    echo "✅ boto3 installed successfully in virtual environment"
else
    echo "✅ boto3 is already available in virtual environment"
fi

# Get knowledge base ID from AWS
echo "Looking up knowledge base ID..."
KB_ID=$(aws bedrock-agent list-knowledge-bases --query 'knowledgeBaseSummaries[?name==`AWS-Services-KB`].knowledgeBaseId' --output text)

if [ -z "$KB_ID" ] || [ "$KB_ID" == "None" ]; then
    echo "❌ AWS-Services-KB not found. Please create the knowledge base via the AWS Console first."
    echo "   Follow the README instructions to create the knowledge base using the console."
    deactivate
    exit 1
fi

echo "✅ Found AWS-Services-KB with ID: $KB_ID"

# Create Python script to test the knowledge base
cat > test_knowledge_base.py << EOF
import boto3
import json
from datetime import datetime
import sys

def test_knowledge_base():
    print("🔧 Initializing Bedrock Agent Runtime client...")
    
    try:
        # Initialize the Bedrock Agent Runtime client
        client = boto3.client('bedrock-agent-runtime')
        print("✅ Bedrock client initialized successfully")
    except Exception as e:
        print(f"❌ Failed to initialize Bedrock client: {str(e)}")
        return []
    
    kb_id = '$KB_ID'
    
    # Test queries
    test_queries = [
        {
            'query': "What is Amazon EC2?",
            'file': 'kb-response-ec2.json',
            'emoji': '💻'
        },
        {
            'query': "Tell me about Amazon Bedrock features",
            'file': 'kb-response-bedrock.json',
            'emoji': '🤖'
        },
        {
            'query': "What are the AWS Well-Architected Framework pillars?",
            'file': 'kb-response-well-architected.json',
            'emoji': '🏗️'
        },
        {
            'query': "How does Amazon S3 work?",
            'file': 'kb-response-s3.json',
            'emoji': '🪣'
        }
    ]
    
    results = []
    
    for i, test in enumerate(test_queries, 1):
        print(f"\n{test['emoji']} Test {i}: {test['query']}")
        
        try:
            print(f"   📡 Querying knowledge base...")
            
            # Query the knowledge base
            response = client.retrieve(
                knowledgeBaseId=kb_id,
                retrievalQuery={
                    'text': test['query']
                },
                retrievalConfiguration={
                    'vectorSearchConfiguration': {
                        'numberOfResults': 3
                    }
                }
            )
            
            print(f"   📥 Processing retrieval results...")
            
            # Process the response
            retrieval_results = response.get('retrievalResults', [])
            
            # Format the response
            formatted_response = {
                'query': test['query'],
                'timestamp': datetime.now().isoformat(),
                'knowledge_base_id': kb_id,
                'results_count': len(retrieval_results),
                'results': []
            }
            
            for result in retrieval_results:
                formatted_result = {
                    'content': result.get('content', {}).get('text', ''),
                    'score': result.get('score', 0),
                    'location': result.get('location', {}).get('s3Location', {}).get('uri', ''),
                    'metadata': result.get('metadata', {})
                }
                formatted_response['results'].append(formatted_result)
            
            # Save response to file
            with open(test['file'], 'w') as f:
                json.dump(formatted_response, f, indent=2)
            
            print(f"   ✅ Query successful - {len(retrieval_results)} results found")
            print(f"   📄 Response saved to {test['file']}")
            
            # Show preview of first result
            if retrieval_results:
                first_result = retrieval_results[0]
                content_preview = first_result.get('content', {}).get('text', '')[:100]
                score = first_result.get('score', 0)
                print(f"   📝 Top result (score: {score:.3f}): {content_preview}...")
            
            results.append({
                'success': True, 
                'file': test['file'], 
                'results_count': len(retrieval_results),
                'top_score': retrieval_results[0].get('score', 0) if retrieval_results else 0
            })
            
        except Exception as e:
            print(f"   ❌ Query failed: {str(e)}")
            results.append({'success': False, 'error': str(e)})
    
    return results

if __name__ == "__main__":
    print("🐍 Testing Bedrock Knowledge Base with Python boto3...")
    print(f"🔧 Using Python: {sys.executable}")
    print(f"🔧 boto3 version: {boto3.__version__}")
    
    results = test_knowledge_base()
    
    print("\n📊 Test Results Summary:")
    print("=" * 60)
    
    success_count = 0
    total_results = 0
    
    for i, result in enumerate(results, 1):
        if result['success']:
            success_count += 1
            total_results += result['results_count']
            print(f"Test {i}: ✅ Success ({result['results_count']} results, top score: {result['top_score']:.3f})")
        else:
            print(f"Test {i}: ❌ Failed - {result['error']}")
        print()
    
    print(f"🎯 Results: {success_count}/{len(results)} tests passed")
    print(f"📊 Total knowledge base results retrieved: {total_results}")
    print("🎉 Knowledge base testing completed!")
    print("💡 Tip: Check the generated JSON files for full retrieval results.")
EOF

echo ""
echo "🐍 Running Python test script in virtual environment..."
python test_knowledge_base.py

# Store the exit code
TEST_EXIT_CODE=$?

# Check if test was successful
if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo ""
    echo "📄 Generated Response Files:"
    echo "============================"
    
    for file in kb-response-*.json; do
        if [ -f "$file" ]; then
            echo "📁 $file"
            RESULTS_COUNT=$(python -c "import json; data=json.load(open('$file')); print(data['results_count'])" 2>/dev/null || echo "Could not read file")
            echo "   Results: $RESULTS_COUNT"
            echo ""
        fi
    done
else
    echo ""
    echo "⚠️  Python test failed. You can still test the knowledge base manually:"
    echo "   1. Go to AWS Console → Amazon Bedrock → Knowledge bases"
    echo "   2. Select your AWS-Services-KB"
    echo "   3. Click 'Test knowledge base'"
    echo "   4. Try queries like 'What is Amazon EC2?'"
fi

# Deactivate virtual environment
echo "🔧 Deactivating virtual environment..."
deactivate

# Clean up the temporary Python script
rm -f test_knowledge_base.py

echo ""
echo "🎯 Testing completed!"
echo "💡 Virtual environment preserved at: $VENV_DIR"
echo "   (Will be cleaned up when you run cleanup.sh)"
