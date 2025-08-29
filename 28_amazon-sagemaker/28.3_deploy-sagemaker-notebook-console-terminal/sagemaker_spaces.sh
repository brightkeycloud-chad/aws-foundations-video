#!/bin/bash

# SageMaker AI Spaces Cost Analysis Script
# This script identifies existing SageMaker AI spaces and their cost-generating resources

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if jq is installed for JSON parsing
if ! command -v jq &> /dev/null; then
    print_error "jq is not installed. Please install it for JSON parsing."
    exit 1
fi

# Get AWS region (use default if not set)
REGION=${AWS_DEFAULT_REGION:-$(aws configure get region)}
if [ -z "$REGION" ]; then
    print_error "AWS region not set. Please set AWS_DEFAULT_REGION or configure AWS CLI."
    exit 1
fi

print_info "Analyzing SageMaker AI spaces in region: $REGION"
echo "=================================================="

# Function to get all SageMaker domains
get_domains() {
    aws sagemaker list-domains --region "$REGION" --query 'Domains[].{DomainId:DomainId,DomainName:DomainName,Status:Status}' --output json 2>/dev/null
}

# Function to get spaces for a domain
get_spaces() {
    local domain_id=$1
    aws sagemaker list-spaces --region "$REGION" --domain-id "$domain_id" --query 'Spaces[].{SpaceName:SpaceName,Status:Status,CreationTime:CreationTime,LastModifiedTime:LastModifiedTime}' --output json 2>/dev/null
}

# Function to get space details
get_space_details() {
    local domain_id=$1
    local space_name=$2
    aws sagemaker describe-space --region "$REGION" --domain-id "$domain_id" --space-name "$space_name" --output json 2>/dev/null
}

# Function to get running apps in a space
get_space_apps() {
    local domain_id=$1
    local space_name=$2
    aws sagemaker list-apps --region "$REGION" --domain-id "$domain_id" --space-name "$space_name" --query 'Apps[?Status==`InService`].{AppType:AppType,AppName:AppName,Status:Status,CreationTime:CreationTime}' --output json 2>/dev/null
}

# Main analysis function
analyze_spaces() {
    local total_spaces=0
    local active_spaces=0
    local cost_generating_spaces=0
    
    # Get all domains
    domains=$(get_domains)
    
    if [ "$domains" = "[]" ] || [ -z "$domains" ]; then
        print_warning "No SageMaker domains found in region $REGION"
        return
    fi
    
    echo "$domains" | jq -r '.[] | @base64' | while IFS= read -r domain_data; do
        domain_json=$(echo "$domain_data" | base64 --decode)
        domain_id=$(echo "$domain_json" | jq -r '.DomainId')
        domain_name=$(echo "$domain_json" | jq -r '.DomainName')
        domain_status=$(echo "$domain_json" | jq -r '.Status')
        
        print_info "Domain: $domain_name ($domain_id) - Status: $domain_status"
        
        if [ "$domain_status" != "InService" ]; then
            print_warning "  Domain is not in service, skipping..."
            continue
        fi
        
        # Get spaces for this domain
        spaces=$(get_spaces "$domain_id")
        
        if [ "$spaces" = "[]" ] || [ -z "$spaces" ]; then
            print_info "  No spaces found in this domain"
            continue
        fi
        
        echo "$spaces" | jq -r '.[] | @base64' | while IFS= read -r space_data; do
            space_json=$(echo "$space_data" | base64 --decode)
            space_name=$(echo "$space_json" | jq -r '.SpaceName')
            space_status=$(echo "$space_json" | jq -r '.Status')
            creation_time=$(echo "$space_json" | jq -r '.CreationTime')
            
            total_spaces=$((total_spaces + 1))
            
            echo "  ├── Space: $space_name"
            echo "  │   Status: $space_status"
            echo "  │   Created: $creation_time"
            
            if [ "$space_status" = "InService" ]; then
                active_spaces=$((active_spaces + 1))
                
                # Get space details for resource information
                space_details=$(get_space_details "$domain_id" "$space_name")
                
                # Check for running apps
                running_apps=$(get_space_apps "$domain_id" "$space_name")
                
                if [ "$running_apps" != "[]" ] && [ -n "$running_apps" ]; then
                    cost_generating_spaces=$((cost_generating_spaces + 1))
                    print_warning "  │   ⚠️  COST GENERATING - Running Apps Found:"
                    
                    echo "$running_apps" | jq -r '.[] | "  │       - " + .AppType + "/" + .AppName + " (Status: " + .Status + ", Created: " + .CreationTime + ")"'
                else
                    print_success "  │   ✅ No running apps (minimal cost)"
                fi
                
                # Check for storage settings that might incur costs
                if [ -n "$space_details" ]; then
                    storage_settings=$(echo "$space_details" | jq -r '.SpaceSettings.SpaceStorageSettings // empty')
                    if [ -n "$storage_settings" ] && [ "$storage_settings" != "null" ]; then
                        print_info "  │   💾 Storage configured (EFS costs may apply)"
                    fi
                fi
            else
                print_info "  │   Status: $space_status (not generating compute costs)"
            fi
            
            echo "  │"
        done
    done
    
    echo "=================================================="
    print_info "Summary:"
    echo "  Total Spaces: $total_spaces"
    echo "  Active Spaces: $active_spaces"
    echo "  Cost-Generating Spaces: $cost_generating_spaces"
    
    if [ $cost_generating_spaces -gt 0 ]; then
        print_warning "Found $cost_generating_spaces spaces with running applications that are generating costs!"
        echo ""
        print_info "To reduce costs, consider:"
        echo "  1. Stop unused applications in SageMaker Studio"
        echo "  2. Use auto-shutdown policies for idle resources"
        echo "  3. Monitor usage with AWS Cost Explorer"
        echo "  4. Enable cost allocation tags for better tracking"
    else
        print_success "No spaces with running applications found. Costs should be minimal (storage only)."
    fi
}

# Function to show help
show_help() {
    echo "SageMaker AI Spaces Cost Analysis Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -r, --region REGION    Specify AWS region (overrides default)"
    echo "  -h, --help            Show this help message"
    echo ""
    echo "This script identifies SageMaker AI spaces that are generating costs by:"
    echo "  - Listing all SageMaker domains in the specified region"
    echo "  - Checking each space's status and running applications"
    echo "  - Identifying spaces with active apps that incur compute costs"
    echo ""
    echo "Prerequisites:"
    echo "  - AWS CLI installed and configured"
    echo "  - jq installed for JSON parsing"
    echo "  - Appropriate IAM permissions for SageMaker operations"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -r|--region)
            REGION="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Run the analysis
analyze_spaces
