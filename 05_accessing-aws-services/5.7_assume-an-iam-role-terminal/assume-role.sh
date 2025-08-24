#!/bin/bash

# Function to assume a role and export credentials
assume_role() {
    local role_arn=$1
    local session_name=${2:-"cli-session-$(date +%s)"}
    local duration=${3:-3600}
    
    echo "Assuming role: $role_arn"
    
    # Assume the role
    local output=$(aws sts assume-role \
        --role-arn "$role_arn" \
        --role-session-name "$session_name" \
        --duration-seconds "$duration" 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        # Export the credentials
        export AWS_ACCESS_KEY_ID=$(echo "$output" | jq -r '.Credentials.AccessKeyId')
        export AWS_SECRET_ACCESS_KEY=$(echo "$output" | jq -r '.Credentials.SecretAccessKey')
        export AWS_SESSION_TOKEN=$(echo "$output" | jq -r '.Credentials.SessionToken')
        
        echo "✅ Successfully assumed role!"
        echo "Session expires: $(echo "$output" | jq -r '.Credentials.Expiration')"
        
        # Verify the assumption
        aws sts get-caller-identity
    else
        echo "❌ Failed to assume role"
        return 1
    fi
}

# Usage example
if [ $# -eq 0 ]; then
    echo "Usage: $0 <role-arn> [session-name] [duration-seconds]"
    echo "Example: $0 arn:aws:iam::123456789012:role/MyRole my-session 3600"
    exit 1
fi

assume_role "$@"