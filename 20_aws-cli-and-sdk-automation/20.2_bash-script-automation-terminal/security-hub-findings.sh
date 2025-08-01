#!/bin/bash

# AWS Security Hub Critical Findings Script
# Retrieves and displays the first 10 critical security findings in a formatted table

set -e

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REGION="us-east-1"
MAX_RESULTS=10
SEVERITY="CRITICAL"

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Retrieve and display AWS Security Hub critical findings"
    echo
    echo "Options:"
    echo "  -r, --region REGION     AWS region (default: us-east-1)"
    echo "  -s, --severity LEVEL    Severity level: CRITICAL|HIGH|MEDIUM|LOW (default: CRITICAL)"
    echo "  -n, --number COUNT      Number of findings to display (default: 10)"
    echo "  -h, --help             Show this help"
    echo
    echo "Examples:"
    echo "  $0                                    # Show 10 critical findings in us-east-1"
    echo "  $0 --region us-west-2 --number 5     # Show 5 critical findings in us-west-2"
    echo "  $0 --severity HIGH --number 15       # Show 15 high severity findings"
    exit 1
}

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -r|--region)
            REGION="$2"
            shift 2
            ;;
        -s|--severity)
            SEVERITY="$2"
            shift 2
            ;;
        -n|--number)
            MAX_RESULTS="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Validate severity level
if [[ ! "$SEVERITY" =~ ^(CRITICAL|HIGH|MEDIUM|LOW)$ ]]; then
    error "Invalid severity level: $SEVERITY"
    echo "Valid levels: CRITICAL, HIGH, MEDIUM, LOW"
    exit 1
fi

# Validate max results
if ! [[ "$MAX_RESULTS" =~ ^[0-9]+$ ]] || [ "$MAX_RESULTS" -lt 1 ] || [ "$MAX_RESULTS" -gt 100 ]; then
    error "Invalid number of results: $MAX_RESULTS"
    echo "Must be a number between 1 and 100"
    exit 1
fi

# Function to check AWS credentials and Security Hub status
check_prerequisites() {
    log "Checking AWS credentials and Security Hub status..."
    
    # Check AWS credentials
    if ! aws sts get-caller-identity --region "$REGION" > /dev/null 2>&1; then
        error "AWS CLI not configured or invalid credentials for region $REGION"
        exit 1
    fi
    
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text --region "$REGION")
    log "Account ID: $ACCOUNT_ID"
    log "Region: $REGION"
    
    # Check if Security Hub is enabled
    if ! aws securityhub describe-hub --region "$REGION" > /dev/null 2>&1; then
        error "Security Hub is not enabled in region $REGION"
        echo "To enable Security Hub, run:"
        echo "  aws securityhub enable-security-hub --region $REGION"
        exit 1
    fi
    
    info "✓ Security Hub is enabled in region $REGION"
}

# Function to get Security Hub findings
get_security_findings() {
    log "Retrieving $SEVERITY severity findings (max: $MAX_RESULTS)..."
    
    # Create filter for severity
    FILTER="{\"SeverityLabel\":[{\"Value\":\"$SEVERITY\",\"Comparison\":\"EQUALS\"}],\"RecordState\":[{\"Value\":\"ACTIVE\",\"Comparison\":\"EQUALS\"}]}"
    
    # Get findings from Security Hub
    FINDINGS_JSON=$(aws securityhub get-findings \
        --filters "$FILTER" \
        --max-results "$MAX_RESULTS" \
        --region "$REGION" \
        --query 'Findings[*].{
            Id: Id,
            Title: Title,
            Severity: Severity.Label,
            Status: Compliance.Status,
            ResourceType: Resources[0].Type,
            ResourceId: Resources[0].Id,
            CreatedAt: CreatedAt,
            UpdatedAt: UpdatedAt,
            GeneratorId: GeneratorId
        }' \
        --output json 2>/dev/null)
    
    if [[ $? -ne 0 ]]; then
        error "Failed to retrieve Security Hub findings"
        echo "This could be due to:"
        echo "  - Security Hub not enabled in the region"
        echo "  - Insufficient permissions"
        echo "  - No findings available"
        exit 1
    fi
    
    # Check if we got any findings
    FINDING_COUNT=$(echo "$FINDINGS_JSON" | jq '. | length' 2>/dev/null || echo "0")
    
    if [[ "$FINDING_COUNT" -eq 0 ]]; then
        info "No $SEVERITY severity findings found in region $REGION"
        echo
        echo "This could mean:"
        echo "  - No critical security issues detected (good news!)"
        echo "  - Security standards are not enabled"
        echo "  - Findings have been resolved or suppressed"
        echo
        echo "To check Security Hub status:"
        echo "  aws securityhub get-enabled-standards --region $REGION"
        return 0
    fi
    
    info "Found $FINDING_COUNT $SEVERITY severity findings"
    echo
    
    # Display findings in a formatted table
    display_findings_table "$FINDINGS_JSON"
}

# Function to display findings in a formatted table
display_findings_table() {
    local findings_json="$1"
    
    echo -e "${RED}=== AWS Security Hub $SEVERITY Findings ===${NC}"
    echo -e "${BLUE}Region: $REGION | Account: $(aws sts get-caller-identity --query Account --output text --region "$REGION")${NC}"
    echo
    
    # Create table header
    printf "%-3s %-50s %-10s %-15s %-20s %-15s\n" \
        "No." "Title" "Severity" "Status" "Resource Type" "Created"
    
    printf "%-3s %-50s %-10s %-15s %-20s %-15s\n" \
        "---" "$(printf '%*s' 50 '' | tr ' ' '-')" \
        "$(printf '%*s' 10 '' | tr ' ' '-')" \
        "$(printf '%*s' 15 '' | tr ' ' '-')" \
        "$(printf '%*s' 20 '' | tr ' ' '-')" \
        "$(printf '%*s' 15 '' | tr ' ' '-')"
    
    # Process each finding
    local counter=1
    echo "$findings_json" | jq -r '.[] | @base64' | while read -r finding; do
        # Decode the base64 encoded JSON
        local decoded=$(echo "$finding" | base64 --decode)
        
        # Extract fields
        local title=$(echo "$decoded" | jq -r '.Title // "N/A"' | cut -c1-47)
        local severity=$(echo "$decoded" | jq -r '.Severity // "N/A"')
        local status=$(echo "$decoded" | jq -r '.Status // "N/A"')
        local resource_type=$(echo "$decoded" | jq -r '.ResourceType // "N/A"' | sed 's/.*:://' | cut -c1-17)
        local created_at=$(echo "$decoded" | jq -r '.CreatedAt // "N/A"' | cut -c1-10)
        
        # Add ellipsis if title is truncated
        if [[ ${#title} -eq 47 ]] && [[ $(echo "$decoded" | jq -r '.Title // "N/A"' | wc -c) -gt 48 ]]; then
            title="${title}..."
        fi
        
        # Color code severity
        case $severity in
            "CRITICAL")
                severity_colored="\033[0;31m$severity\033[0m"
                ;;
            "HIGH")
                severity_colored="\033[0;33m$severity\033[0m"
                ;;
            *)
                severity_colored="$severity"
                ;;
        esac
        
        # Print table row
        printf "%-3s %-50s %-10s %-15s %-20s %-15s\n" \
            "$counter" "$title" "$severity" "$status" "$resource_type" "$created_at"
        
        ((counter++))
    done
    
    echo
    info "Showing first $MAX_RESULTS findings (if available)"
    
    # Show additional information
    echo
    echo -e "${YELLOW}Additional Commands:${NC}"
    echo "  View detailed finding: aws securityhub get-findings --filters '{\"Id\":[{\"Value\":\"FINDING_ID\",\"Comparison\":\"EQUALS\"}]}' --region $REGION"
    echo "  List all standards:    aws securityhub get-enabled-standards --region $REGION"
    echo "  Security Hub console:  https://$REGION.console.aws.amazon.com/securityhub/"
}

# Function to show summary statistics
show_summary_stats() {
    log "Generating Security Hub summary statistics..."
    
    # Get counts by severity
    local critical_count=$(aws securityhub get-findings \
        --filters '{"SeverityLabel":[{"Value":"CRITICAL","Comparison":"EQUALS"}],"RecordState":[{"Value":"ACTIVE","Comparison":"EQUALS"}]}' \
        --max-results 100 \
        --region "$REGION" \
        --query 'length(Findings)' \
        --output text 2>/dev/null || echo "0")
    
    local high_count=$(aws securityhub get-findings \
        --filters '{"SeverityLabel":[{"Value":"HIGH","Comparison":"EQUALS"}],"RecordState":[{"Value":"ACTIVE","Comparison":"EQUALS"}]}' \
        --max-results 100 \
        --region "$REGION" \
        --query 'length(Findings)' \
        --output text 2>/dev/null || echo "0")
    
    local medium_count=$(aws securityhub get-findings \
        --filters '{"SeverityLabel":[{"Value":"MEDIUM","Comparison":"EQUALS"}],"RecordState":[{"Value":"ACTIVE","Comparison":"EQUALS"}]}' \
        --max-results 100 \
        --region "$REGION" \
        --query 'length(Findings)' \
        --output text 2>/dev/null || echo "0")
    
    echo
    echo -e "${BLUE}=== Security Hub Summary ===${NC}"
    printf "%-12s %s\n" "Critical:" "$critical_count"
    printf "%-12s %s\n" "High:" "$high_count"
    printf "%-12s %s\n" "Medium:" "$medium_count"
    echo
}

# Main execution function
main() {
    info "AWS Security Hub Critical Findings Report"
    info "Severity: $SEVERITY | Region: $REGION | Max Results: $MAX_RESULTS"
    echo
    
    # Check prerequisites
    check_prerequisites
    
    # Get and display findings
    get_security_findings
    
    # Show summary if looking at critical findings
    if [[ "$SEVERITY" == "CRITICAL" ]]; then
        show_summary_stats
    fi
}

# Error handling
trap 'error "Script failed at line $LINENO"' ERR

# Run main function
main "$@"
