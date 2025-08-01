#!/usr/bin/env python3
"""
AWS Security Hub Findings Analyzer using Python/Boto3
Demonstrates advanced Python capabilities for security monitoring
PYTHON ADVANTAGES: Better data processing, object-oriented design, exception handling
"""

import boto3
import json
import argparse
import pandas as pd
from datetime import datetime, timezone
from typing import List, Dict, Optional
from botocore.exceptions import ClientError, NoCredentialsError
import logging

class SecurityHubAnalyzer:
    """
    Advanced Security Hub analyzer with Python-specific advantages:
    - Object-oriented design for better code organization
    - Type hints for better code documentation
    - Pandas for advanced data manipulation
    - Rich exception handling with specific error types
    """
    
    def __init__(self, region: str = 'us-east-1'):
        self.region = region
        self.logger = self._setup_logging()
        
        try:
            self.securityhub_client = boto3.client('securityhub', region_name=region)
            self.sts_client = boto3.client('sts', region_name=region)
            
            # Verify credentials and Security Hub status
            self._verify_prerequisites()
            
        except NoCredentialsError:
            self.logger.error("AWS credentials not configured")
            raise
        except Exception as e:
            self.logger.error(f"Failed to initialize Security Hub client: {e}")
            raise
    
    def _setup_logging(self) -> logging.Logger:
        """Setup logging configuration"""
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s'
        )
        return logging.getLogger(__name__)
    
    def _verify_prerequisites(self) -> None:
        """Verify AWS credentials and Security Hub status"""
        try:
            # Check credentials
            identity = self.sts_client.get_caller_identity()
            self.account_id = identity['Account']
            self.logger.info(f"Connected to account: {self.account_id}")
            
            # Check Security Hub status
            hub_info = self.securityhub_client.describe_hub()
            self.logger.info(f"✓ Security Hub enabled in {self.region}")
            
        except ClientError as e:
            error_code = e.response['Error']['Code']
            if error_code == 'InvalidAccessException':
                raise Exception(f"Security Hub not enabled in {self.region}. Enable with: aws securityhub enable-security-hub --region {self.region}")
            else:
                raise Exception(f"Security Hub access error: {e}")
    
    def get_findings(self, 
                    severity: str = 'CRITICAL', 
                    max_results: int = 10,
                    include_suppressed: bool = False) -> List[Dict]:
        """
        Get Security Hub findings with advanced filtering
        PYTHON ADVANTAGE: Type hints, default parameters, better data structures
        """
        try:
            self.logger.info(f"Retrieving {severity} findings (max: {max_results})")
            
            # Build filters - Python makes complex data structures easier
            filters = {
                'SeverityLabel': [{'Value': severity, 'Comparison': 'EQUALS'}]
            }
            
            if not include_suppressed:
                filters['RecordState'] = [{'Value': 'ACTIVE', 'Comparison': 'EQUALS'}]
            
            # Get findings with pagination support (Python handles this elegantly)
            findings = []
            paginator = self.securityhub_client.get_paginator('get_findings')
            
            for page in paginator.paginate(
                Filters=filters,
                PaginationConfig={'MaxItems': max_results}
            ):
                findings.extend(page['Findings'])
                if len(findings) >= max_results:
                    break
            
            self.logger.info(f"Retrieved {len(findings)} findings")
            return findings[:max_results]
            
        except ClientError as e:
            self.logger.error(f"Failed to retrieve findings: {e}")
            raise
    
    def analyze_findings(self, findings: List[Dict]) -> Dict:
        """
        Analyze findings with advanced Python data processing
        PYTHON ADVANTAGE: Rich data analysis capabilities with pandas
        """
        if not findings:
            return {'message': 'No findings to analyze'}
        
        try:
            # Convert to pandas DataFrame for advanced analysis
            # This is much easier in Python than bash!
            df_data = []
            for finding in findings:
                # Extract nested data safely
                resource = finding.get('Resources', [{}])[0]
                severity_info = finding.get('Severity', {})
                
                df_data.append({
                    'Id': finding.get('Id', 'N/A'),
                    'Title': finding.get('Title', 'N/A'),
                    'Severity': severity_info.get('Label', 'N/A'),
                    'Score': severity_info.get('Normalized', 0),
                    'Status': finding.get('Compliance', {}).get('Status', 'N/A'),
                    'ResourceType': resource.get('Type', 'N/A'),
                    'ResourceId': resource.get('Id', 'N/A'),
                    'GeneratorId': finding.get('GeneratorId', 'N/A'),
                    'CreatedAt': finding.get('CreatedAt', 'N/A'),
                    'UpdatedAt': finding.get('UpdatedAt', 'N/A')
                })
            
            df = pd.DataFrame(df_data)
            
            # Perform analysis that would be very difficult in bash
            analysis = {
                'total_findings': len(df),
                'unique_resource_types': df['ResourceType'].nunique(),
                'resource_type_distribution': df['ResourceType'].value_counts().to_dict(),
                'status_distribution': df['Status'].value_counts().to_dict(),
                'average_severity_score': df['Score'].mean(),
                'findings_by_generator': df['GeneratorId'].value_counts().head(5).to_dict()
            }
            
            self.logger.info("✓ Advanced analysis completed")
            return analysis
            
        except Exception as e:
            self.logger.error(f"Analysis failed: {e}")
            raise
    
    def display_findings_table(self, findings: List[Dict]) -> None:
        """
        Display findings in a formatted table
        PYTHON ADVANTAGE: Better string formatting and data manipulation
        """
        if not findings:
            print("No findings to display")
            return
        
        print(f"\n{'='*80}")
        print(f"AWS Security Hub Findings - {self.region}")
        print(f"Account: {self.account_id} | Timestamp: {datetime.now()}")
        print(f"{'='*80}")
        
        # Create formatted table - Python's string formatting is superior
        headers = ['#', 'Title', 'Severity', 'Status', 'Resource Type', 'Created']
        col_widths = [3, 45, 10, 12, 20, 12]
        
        # Print header
        header_row = ""
        for i, (header, width) in enumerate(zip(headers, col_widths)):
            header_row += f"{header:<{width}} "
        print(header_row)
        print("-" * len(header_row))
        
        # Print findings
        for i, finding in enumerate(findings, 1):
            resource = finding.get('Resources', [{}])[0]
            severity = finding.get('Severity', {}).get('Label', 'N/A')
            status = finding.get('Compliance', {}).get('Status', 'N/A')
            
            # Truncate long titles intelligently
            title = finding.get('Title', 'N/A')
            if len(title) > 42:
                title = title[:39] + "..."
            
            # Format resource type
            resource_type = resource.get('Type', 'N/A')
            if '::' in resource_type:
                resource_type = resource_type.split('::')[-1]
            
            # Format date
            created_at = finding.get('CreatedAt', 'N/A')
            if created_at != 'N/A':
                try:
                    created_date = datetime.fromisoformat(created_at.replace('Z', '+00:00'))
                    created_at = created_date.strftime('%Y-%m-%d')
                except:
                    created_at = 'N/A'
            
            # Print row with proper formatting
            row_data = [str(i), title, severity, status, resource_type[:17], created_at]
            row = ""
            for data, width in zip(row_data, col_widths):
                row += f"{data:<{width}} "
            print(row)
        
        print(f"\nShowing {len(findings)} findings")
    
    def export_findings(self, findings: List[Dict], format: str = 'json') -> str:
        """
        Export findings to various formats
        PYTHON ADVANTAGE: Easy serialization to multiple formats
        """
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        if format.lower() == 'json':
            filename = f"security_findings_{timestamp}.json"
            with open(filename, 'w') as f:
                json.dump(findings, f, indent=2, default=str)
        
        elif format.lower() == 'csv':
            filename = f"security_findings_{timestamp}.csv"
            # Convert to flat structure for CSV
            flat_data = []
            for finding in findings:
                resource = finding.get('Resources', [{}])[0]
                flat_data.append({
                    'Id': finding.get('Id'),
                    'Title': finding.get('Title'),
                    'Severity': finding.get('Severity', {}).get('Label'),
                    'Status': finding.get('Compliance', {}).get('Status'),
                    'ResourceType': resource.get('Type'),
                    'ResourceId': resource.get('Id'),
                    'CreatedAt': finding.get('CreatedAt'),
                    'UpdatedAt': finding.get('UpdatedAt')
                })
            
            df = pd.DataFrame(flat_data)
            df.to_csv(filename, index=False)
        
        else:
            raise ValueError(f"Unsupported format: {format}")
        
        self.logger.info(f"✓ Findings exported to {filename}")
        return filename
    
    def get_summary_statistics(self) -> Dict:
        """
        Get comprehensive Security Hub statistics
        PYTHON ADVANTAGE: Complex data aggregation and statistical analysis
        """
        try:
            self.logger.info("Generating comprehensive statistics...")
            
            stats = {}
            severities = ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW']
            
            for severity in severities:
                try:
                    findings = self.get_findings(severity=severity, max_results=100)
                    stats[severity.lower()] = len(findings)
                except:
                    stats[severity.lower()] = 0
            
            # Get enabled standards
            try:
                standards = self.securityhub_client.get_enabled_standards()
                stats['enabled_standards'] = len(standards['StandardsSubscriptions'])
            except:
                stats['enabled_standards'] = 0
            
            return stats
            
        except Exception as e:
            self.logger.error(f"Failed to generate statistics: {e}")
            return {}

def main():
    """
    Main function with advanced argument parsing
    PYTHON ADVANTAGE: argparse is much more powerful than bash argument parsing
    """
    parser = argparse.ArgumentParser(
        description='Advanced AWS Security Hub Findings Analyzer',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s --severity CRITICAL --max-results 10
  %(prog)s --region us-west-2 --severity HIGH --export json
  %(prog)s --analyze --export csv
        """
    )
    
    parser.add_argument('--region', '-r', default='us-east-1',
                       help='AWS region (default: us-east-1)')
    parser.add_argument('--severity', '-s', default='CRITICAL',
                       choices=['CRITICAL', 'HIGH', 'MEDIUM', 'LOW'],
                       help='Severity level (default: CRITICAL)')
    parser.add_argument('--max-results', '-n', type=int, default=10,
                       help='Maximum number of results (default: 10)')
    parser.add_argument('--analyze', action='store_true',
                       help='Perform advanced analysis')
    parser.add_argument('--export', choices=['json', 'csv'],
                       help='Export findings to file')
    parser.add_argument('--stats', action='store_true',
                       help='Show summary statistics')
    
    args = parser.parse_args()
    
    try:
        # Initialize analyzer
        analyzer = SecurityHubAnalyzer(region=args.region)
        
        # Get findings
        findings = analyzer.get_findings(
            severity=args.severity,
            max_results=args.max_results
        )
        
        # Display findings
        analyzer.display_findings_table(findings)
        
        # Perform analysis if requested
        if args.analyze and findings:
            print(f"\n{'='*50}")
            print("ADVANCED ANALYSIS (Python Advantage)")
            print(f"{'='*50}")
            analysis = analyzer.analyze_findings(findings)
            print(json.dumps(analysis, indent=2))
        
        # Export if requested
        if args.export and findings:
            filename = analyzer.export_findings(findings, args.export)
            print(f"\n✓ Findings exported to {filename}")
        
        # Show statistics if requested
        if args.stats:
            print(f"\n{'='*30}")
            print("SECURITY HUB STATISTICS")
            print(f"{'='*30}")
            stats = analyzer.get_summary_statistics()
            for severity, count in stats.items():
                print(f"{severity.upper():<15}: {count}")
        
    except Exception as e:
        print(f"Error: {e}")
        return 1
    
    return 0

if __name__ == "__main__":
    exit(main())
