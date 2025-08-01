#!/usr/bin/env python3
"""
AWS Security Hub Critical Findings Script - Python Version
Direct analogue to the bash script from 20.2, showcasing Python advantages
"""

import boto3
import argparse
import json
import sys
from datetime import datetime
from typing import List, Dict, Optional
from botocore.exceptions import ClientError, NoCredentialsError

class Colors:
    """ANSI color codes for terminal output"""
    RED = '\033[0;31m'
    YELLOW = '\033[1;33m'
    GREEN = '\033[0;32m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'  # No Color

class SecurityHubFindings:
    """
    AWS Security Hub Findings Retriever
    Python equivalent of bash security-hub-findings.sh script
    
    PYTHON ADVANTAGES:
    - Better error handling with specific exception types
    - Object-oriented design for code organization
    - Native JSON processing without external tools
    - Type hints for better code documentation
    """
    
    def __init__(self, region: str = 'us-east-1'):
        self.region = region
        self.account_id = None
        
        try:
            # Initialize AWS clients - Python handles this more elegantly
            self.securityhub_client = boto3.client('securityhub', region_name=region)
            self.sts_client = boto3.client('sts', region_name=region)
            
        except NoCredentialsError:
            self.error("AWS credentials not configured")
            sys.exit(1)
        except Exception as e:
            self.error(f"Failed to initialize AWS clients: {e}")
            sys.exit(1)
    
    def log(self, message: str) -> None:
        """Log message with timestamp and color"""
        timestamp = datetime.now().strftime('%H:%M:%S')
        print(f"{Colors.GREEN}[{timestamp}] {message}{Colors.NC}")
    
    def info(self, message: str) -> None:
        """Info message with color"""
        print(f"{Colors.BLUE}[INFO] {message}{Colors.NC}")
    
    def warning(self, message: str) -> None:
        """Warning message with color"""
        print(f"{Colors.YELLOW}[WARNING] {message}{Colors.NC}")
    
    def error(self, message: str) -> None:
        """Error message with color"""
        print(f"{Colors.RED}[ERROR] {message}{Colors.NC}")
    
    def check_prerequisites(self) -> None:
        """
        Check AWS credentials and Security Hub status
        PYTHON ADVANTAGE: Specific exception handling vs generic bash errors
        """
        self.log("Checking AWS credentials and Security Hub status...")
        
        try:
            # Check AWS credentials
            identity = self.sts_client.get_caller_identity()
            self.account_id = identity['Account']
            user_arn = identity['Arn']
            
            self.log(f"Account ID: {self.account_id}")
            self.log(f"Region: {self.region}")
            
            # Check if Security Hub is enabled
            self.securityhub_client.describe_hub()
            self.info(f"✓ Security Hub is enabled in region {self.region}")
            
        except ClientError as e:
            error_code = e.response['Error']['Code']
            if error_code == 'InvalidAccessException':
                self.error(f"Security Hub is not enabled in region {self.region}")
                print("To enable Security Hub, run:")
                print(f"  aws securityhub enable-security-hub --region {self.region}")
                sys.exit(1)
            else:
                self.error(f"AWS credentials or permissions error: {e}")
                sys.exit(1)
    
    def get_security_findings(self, severity: str, max_results: int) -> List[Dict]:
        """
        Get Security Hub findings
        PYTHON ADVANTAGE: Native dictionary/list handling vs bash arrays
        """
        self.log(f"Retrieving {severity} severity findings (max: {max_results})...")
        
        # Create filter - Python dictionaries are much cleaner than bash
        filters = {
            'SeverityLabel': [{'Value': severity, 'Comparison': 'EQUALS'}],
            'RecordState': [{'Value': 'ACTIVE', 'Comparison': 'EQUALS'}]
        }
        
        try:
            response = self.securityhub_client.get_findings(
                Filters=filters,
                MaxResults=max_results
            )
            
            findings = response.get('Findings', [])
            finding_count = len(findings)
            
            if finding_count == 0:
                self.info(f"No {severity} severity findings found in region {self.region}")
                print("\nThis could mean:")
                print("  - No critical security issues detected (good news!)")
                print("  - Security standards are not enabled")
                print("  - Findings have been resolved or suppressed")
                print("\nTo check Security Hub status:")
                print(f"  aws securityhub get-enabled-standards --region {self.region}")
                return []
            
            self.info(f"Found {finding_count} {severity} severity findings")
            return findings
            
        except ClientError as e:
            self.error("Failed to retrieve Security Hub findings")
            print("This could be due to:")
            print("  - Security Hub not enabled in the region")
            print("  - Insufficient permissions")
            print("  - No findings available")
            sys.exit(1)
    
    def display_findings_table(self, findings: List[Dict]) -> None:
        """
        Display findings in a formatted table
        PYTHON ADVANTAGE: Better string formatting and data extraction
        """
        if not findings:
            return
        
        print(f"\n{Colors.RED}=== AWS Security Hub {findings[0].get('Severity', {}).get('Label', 'UNKNOWN')} Findings ==={Colors.NC}")
        print(f"{Colors.BLUE}Region: {self.region} | Account: {self.account_id}{Colors.NC}")
        print()
        
        # Table headers
        headers = ["No.", "Title", "Severity", "Status", "Resource Type", "Created"]
        col_widths = [3, 50, 10, 15, 20, 15]
        
        # Print header row
        header_row = ""
        for header, width in zip(headers, col_widths):
            header_row += f"{header:<{width}} "
        print(header_row)
        
        # Print separator
        separator = ""
        for width in col_widths:
            separator += "-" * width + " "
        print(separator)
        
        # Print findings - Python's data extraction is much cleaner than bash
        for i, finding in enumerate(findings, 1):
            # Extract data safely with Python's get() method
            title = finding.get('Title', 'N/A')
            if len(title) > 47:
                title = title[:44] + "..."
            
            severity = finding.get('Severity', {}).get('Label', 'N/A')
            
            # Handle compliance status safely
            compliance = finding.get('Compliance', {})
            status = compliance.get('Status', 'N/A') if compliance else 'N/A'
            
            # Extract resource type
            resources = finding.get('Resources', [])
            if resources:
                resource_type = resources[0].get('Type', 'N/A')
                # Clean up resource type (remove AWS:: prefix)
                if '::' in resource_type:
                    resource_type = resource_type.split('::')[-1]
                if len(resource_type) > 17:
                    resource_type = resource_type[:17]
            else:
                resource_type = 'N/A'
            
            # Format creation date
            created_at = finding.get('CreatedAt', 'N/A')
            if created_at != 'N/A':
                try:
                    # Python's datetime handling is superior to bash date parsing
                    if isinstance(created_at, str):
                        created_date = datetime.fromisoformat(created_at.replace('Z', '+00:00'))
                    else:
                        created_date = created_at
                    created_at = created_date.strftime('%Y-%m-%d')
                except:
                    created_at = 'N/A'
            
            # Print row
            row_data = [str(i), title, severity, status, resource_type, created_at]
            row = ""
            for data, width in zip(row_data, col_widths):
                row += f"{data:<{width}} "
            print(row)
        
        print()
        self.info(f"Showing first {len(findings)} findings (if available)")
        
        # Show additional information
        print(f"\n{Colors.YELLOW}Additional Commands:{Colors.NC}")
        print(f"  View detailed finding: aws securityhub get-findings --filters '{{\"Id\":[{{\"Value\":\"FINDING_ID\",\"Comparison\":\"EQUALS\"}}]}}' --region {self.region}")
        print(f"  List all standards:    aws securityhub get-enabled-standards --region {self.region}")
        print(f"  Security Hub console:  https://{self.region}.console.aws.amazon.com/securityhub/")
    
    def show_summary_stats(self) -> None:
        """
        Show summary statistics across severity levels
        PYTHON ADVANTAGE: Easy to make multiple API calls and aggregate data
        """
        self.log("Generating Security Hub summary statistics...")
        
        severities = ['CRITICAL', 'HIGH', 'MEDIUM']
        stats = {}
        
        for severity in severities:
            try:
                filters = {
                    'SeverityLabel': [{'Value': severity, 'Comparison': 'EQUALS'}],
                    'RecordState': [{'Value': 'ACTIVE', 'Comparison': 'EQUALS'}]
                }
                
                response = self.securityhub_client.get_findings(
                    Filters=filters,
                    MaxResults=100  # Get more for accurate count
                )
                
                stats[severity] = len(response.get('Findings', []))
                
            except ClientError:
                stats[severity] = 0
        
        print(f"\n{Colors.BLUE}=== Security Hub Summary ==={Colors.NC}")
        for severity, count in stats.items():
            print(f"{severity:<12}: {count}")
        print()

def main():
    """
    Main function with argument parsing
    PYTHON ADVANTAGE: argparse is much more sophisticated than bash argument parsing
    """
    parser = argparse.ArgumentParser(
        description='Retrieve and display AWS Security Hub critical findings',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s                                    # Show 10 critical findings in us-east-1
  %(prog)s --region us-west-2 --number 5     # Show 5 critical findings in us-west-2
  %(prog)s --severity HIGH --number 15       # Show 15 high severity findings
        """
    )
    
    parser.add_argument('--region', '-r', default='us-east-1',
                       help='AWS region (default: us-east-1)')
    parser.add_argument('--severity', '-s', default='CRITICAL',
                       choices=['CRITICAL', 'HIGH', 'MEDIUM', 'LOW'],
                       help='Severity level (default: CRITICAL)')
    parser.add_argument('--number', '-n', type=int, default=10,
                       help='Number of findings to display (default: 10)')
    
    args = parser.parse_args()
    
    # Validate number parameter - Python makes validation easier
    if not 1 <= args.number <= 100:
        print(f"Error: Invalid number of results: {args.number}")
        print("Must be a number between 1 and 100")
        sys.exit(1)
    
    try:
        # Initialize Security Hub client
        security_hub = SecurityHubFindings(region=args.region)
        
        print("AWS Security Hub Critical Findings Report")
        print(f"Severity: {args.severity} | Region: {args.region} | Max Results: {args.number}")
        print()
        
        # Check prerequisites
        security_hub.check_prerequisites()
        
        # Get and display findings
        findings = security_hub.get_security_findings(args.severity, args.number)
        security_hub.display_findings_table(findings)
        
        # Show summary if looking at critical findings
        if args.severity == 'CRITICAL':
            security_hub.show_summary_stats()
        
    except KeyboardInterrupt:
        print("\nOperation cancelled by user")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
