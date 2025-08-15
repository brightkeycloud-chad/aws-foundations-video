#!/usr/bin/env python3

"""
AWS Cost Optimization Enhanced Script
This script uses AWS Cost Explorer API and MCP tools to provide detailed optimization recommendations
"""

import json
import subprocess
import sys
from datetime import datetime, timedelta
from typing import List, Dict, Tuple

def run_aws_command(command: List[str]) -> Dict:
    """Run AWS CLI command and return JSON result"""
    try:
        result = subprocess.run(command, capture_output=True, text=True, check=True)
        return json.loads(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"❌ AWS CLI error: {e.stderr}")
        return {}
    except json.JSONDecodeError:
        print("❌ Failed to parse AWS CLI response")
        return {}

def check_aws_cli():
    """Check if AWS CLI is installed and configured"""
    try:
        subprocess.run(['aws', '--version'], capture_output=True, check=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("❌ AWS CLI not found. Please install AWS CLI first.")
        print("   Installation guide: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html")
        sys.exit(1)
    
    try:
        subprocess.run(['aws', 'sts', 'get-caller-identity'], capture_output=True, check=True)
    except subprocess.CalledProcessError:
        print("❌ AWS CLI not configured. Please run: aws configure")
        sys.exit(1)

def get_top_services() -> List[Tuple[str, float]]:
    """Get top 3 services by cost for previous month (more reliable than current month)"""
    # Calculate previous month date range
    today = datetime.now()
    # First day of current month
    first_current = today.replace(day=1)
    # Last day of previous month
    last_previous = first_current - timedelta(days=1)
    # First day of previous month
    first_previous = last_previous.replace(day=1)
    
    month_start = first_previous.strftime('%Y-%m-%d')
    month_end = last_previous.strftime('%Y-%m-%d')
    
    print(f"📊 Analyzing costs from {month_start} to {month_end} (Previous Month)")
    print("   💡 Using previous month data for more complete cost analysis")
    print("")
    
    # Query Cost Explorer - get raw data first to avoid JMESPath sorting issues
    command = [
        'aws', 'ce', 'get-cost-and-usage',
        '--time-period', f'Start={month_start},End={month_end}',
        '--granularity', 'MONTHLY',
        '--metrics', 'BlendedCost',
        '--group-by', 'Type=DIMENSION,Key=SERVICE',
        '--output', 'json'
    ]
    
    print("🔍 Querying AWS Cost Explorer for top service costs...")
    data = run_aws_command(command)
    
    if not data or 'ResultsByTime' not in data or not data['ResultsByTime']:
        print("❌ No cost data available for the previous month.")
        print("   This could mean:")
        print("   • Cost Explorer is not enabled")
        print("   • No AWS usage in previous month")
        print("   • Data not yet available (wait 24 hours)")
        print("")
        print("🌐 Enable Cost Explorer manually:")
        print("   https://console.aws.amazon.com/costmanagement/")
        return []
    
    # Process the data in Python to handle null values properly
    groups = data['ResultsByTime'][0].get('Groups', [])
    
    # Filter out zero costs and sort
    valid_services = []
    for group in groups:
        cost_amount = group.get('Metrics', {}).get('BlendedCost', {}).get('Amount', '0')
        try:
            cost_float = float(cost_amount)
            if cost_float > 0:
                service_name = group['Keys'][0]
                valid_services.append((service_name, cost_float))
        except (ValueError, TypeError):
            continue
    
    if not valid_services:
        print("❌ No services with costs found for the previous month.")
        print("   This could mean:")
        print("   • All usage was within free tier")
        print("   • Very new account with minimal usage")
        print("   • Data not yet processed (wait 24 hours)")
        print("")
        print("🌐 Enable Cost Explorer manually:")
        print("   https://console.aws.amazon.com/costmanagement/")
        return []
    
    # Sort by cost (highest first) and take top 3
    valid_services.sort(key=lambda x: x[1], reverse=True)
    services = valid_services[:3]
    
    print("✅ Cost data retrieved and processed successfully!")
    print("")
    
    return services

def get_service_optimization_tips(service_name: str, cost: float) -> Dict[str, List[str]]:
    """Get optimization recommendations for a specific service"""
    service_lower = service_name.lower()
    
    recommendations = {
        'immediate': [],
        'medium_term': [],
        'long_term': []
    }
    
    if 'ec2' in service_lower or 'elastic compute cloud' in service_lower:
        recommendations['immediate'] = [
            "Review instance utilization with CloudWatch metrics",
            "Stop unused instances during non-business hours",
            "Use AWS Compute Optimizer recommendations"
        ]
        recommendations['medium_term'] = [
            "Right-size instances based on actual usage patterns",
            "Consider Spot Instances for fault-tolerant workloads (up to 90% savings)",
            "Migrate to newer generation instances (better price/performance)"
        ]
        recommendations['long_term'] = [
            "Purchase Reserved Instances for predictable workloads (up to 75% savings)",
            "Consider Savings Plans for flexible compute commitments",
            "Evaluate AWS Graviton processors for better price/performance"
        ]
    
    elif 's3' in service_lower or 'simple storage service' in service_lower:
        recommendations['immediate'] = [
            "Delete incomplete multipart uploads",
            "Remove old versions and delete markers",
            "Use S3 Storage Lens for usage insights"
        ]
        recommendations['medium_term'] = [
            "Enable S3 Intelligent-Tiering for automatic cost optimization",
            "Move infrequent data to S3 Standard-IA or One Zone-IA",
            "Use S3 Lifecycle policies to transition to cheaper storage classes"
        ]
        recommendations['long_term'] = [
            "Archive old data to S3 Glacier or Glacier Deep Archive",
            "Optimize request patterns to reduce API costs",
            "Consider S3 Transfer Acceleration only for global users"
        ]
    
    elif 'rds' in service_lower or 'relational database service' in service_lower:
        recommendations['immediate'] = [
            "Review database utilization metrics",
            "Stop non-production databases during off-hours",
            "Delete unused snapshots and automated backups"
        ]
        recommendations['medium_term'] = [
            "Right-size database instances based on CPU and memory usage",
            "Consider Aurora Serverless for variable workloads",
            "Migrate from gp2 to gp3 storage (up to 20% cost savings)"
        ]
        recommendations['long_term'] = [
            "Purchase Reserved Instances for production databases",
            "Consider Aurora for better price/performance vs standard RDS",
            "Evaluate read replicas placement and necessity"
        ]
    
    elif 'lambda' in service_lower:
        recommendations['immediate'] = [
            "Review function memory allocation vs actual usage",
            "Optimize function timeout settings",
            "Remove unused functions and versions"
        ]
        recommendations['medium_term'] = [
            "Use ARM-based Graviton2 processors (up to 34% better price/performance)",
            "Optimize function code to reduce execution time",
            "Use provisioned concurrency only when necessary"
        ]
        recommendations['long_term'] = [
            "Consider containerizing workloads for Fargate if appropriate",
            "Implement efficient error handling to reduce retries",
            "Use Lambda layers to reduce deployment package size"
        ]
    
    elif 'cloudfront' in service_lower:
        recommendations['immediate'] = [
            "Review and optimize cache behaviors",
            "Enable compression for text-based content",
            "Remove unused distributions"
        ]
        recommendations['medium_term'] = [
            "Use appropriate price classes for your audience geography",
            "Optimize TTL settings to improve cache hit ratio",
            "Consider origin request policies to reduce origin load"
        ]
        recommendations['long_term'] = [
            "Implement CloudFront Functions for edge computing",
            "Use AWS Global Accelerator for non-HTTP traffic",
            "Optimize content delivery strategy based on user patterns"
        ]
    
    elif 'ebs' in service_lower or 'elastic block store' in service_lower:
        recommendations['immediate'] = [
            "Delete unused volumes and snapshots",
            "Review snapshot retention policies",
            "Identify and remove unattached volumes"
        ]
        recommendations['medium_term'] = [
            "Migrate from gp2 to gp3 volumes (up to 20% cost savings)",
            "Right-size volume capacity based on actual usage",
            "Use appropriate volume types for workload requirements"
        ]
        recommendations['long_term'] = [
            "Implement automated snapshot lifecycle management",
            "Consider EBS-optimized instances for better performance",
            "Evaluate data archival strategies for old snapshots"
        ]
    
    else:
        # Generic recommendations
        recommendations['immediate'] = [
            "Review resource utilization with CloudWatch metrics",
            "Identify and remove unused resources",
            "Set up billing alerts for this service"
        ]
        recommendations['medium_term'] = [
            "Right-size resources based on actual usage patterns",
            "Consider Reserved capacity for predictable workloads",
            "Optimize resource configuration for cost efficiency"
        ]
        recommendations['long_term'] = [
            "Evaluate alternative services or architectures",
            "Implement cost allocation tags for better tracking",
            "Regular cost optimization reviews"
        ]
    
    return recommendations

def display_service_analysis(rank: int, service_name: str, cost: float):
    """Display detailed analysis for a service"""
    print(f"🥇 #{rank}: {service_name}")
    print(f"   💵 Cost: ${cost:.2f}")
    print("")
    
    recommendations = get_service_optimization_tips(service_name, cost)
    
    print("   🚀 IMMEDIATE ACTIONS (This Week):")
    for tip in recommendations['immediate']:
        print(f"      • {tip}")
    print("")
    
    print("   📈 MEDIUM-TERM OPTIMIZATIONS (This Month):")
    for tip in recommendations['medium_term']:
        print(f"      • {tip}")
    print("")
    
    print("   🎯 LONG-TERM STRATEGIES (Next Quarter):")
    for tip in recommendations['long_term']:
        print(f"      • {tip}")
    print("")

def main():
    """Main function"""
    print("💰 AWS Cost Optimization Enhanced Analysis")
    print("==========================================")
    print("")
    
    # Check prerequisites
    check_aws_cli()
    
    # Get top services
    top_services = get_top_services()
    
    if not top_services:
        sys.exit(1)
    
    print("🏆 TOP 3 SERVICE COSTS LAST MONTH:")
    print("==================================")
    print("")
    
    total_cost = 0
    for i, (service_name, cost) in enumerate(top_services, 1):
        display_service_analysis(i, service_name, cost)
        total_cost += cost
        print("-" * 60)
        print("")
    
    print("📊 SUMMARY & NEXT STEPS:")
    print("========================")
    print(f"💰 Total cost of top 3 services: ${total_cost:.2f}")
    print("")
    
    print("🎯 Recommended Action Plan:")
    print("   1. Implement immediate actions for your top cost service this week")
    print("   2. Set up AWS Budgets with alerts for these services")
    print("   3. Schedule monthly cost optimization reviews")
    print("   4. Use AWS Cost Explorer recommendations regularly")
    print("")
    
    print("🛠️ Additional Tools & Resources:")
    print("   • AWS Cost Explorer: https://console.aws.amazon.com/costmanagement/")
    print("   • AWS Pricing Calculator: https://calculator.aws/")
    print("   • AWS Trusted Advisor: Cost optimization checks")
    print("   • AWS Well-Architected Cost Optimization Pillar")
    print("   • AWS Cost Optimization Hub")
    print("")
    
    print("✅ Enhanced cost optimization analysis complete!")
    print("")
    print("💡 Pro Tip: Run this script monthly and track your optimization progress!")

if __name__ == "__main__":
    main()
