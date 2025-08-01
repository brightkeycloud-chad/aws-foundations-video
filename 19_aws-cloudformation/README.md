# AWS CloudFormation Training Demonstrations

This directory contains three hands-on demonstrations for AWS CloudFormation, each designed to be completed in 5 minutes. These demos showcase different deployment methods and AWS services.

## Demo Overview

### 19.3 Deploy VPC Console
**Tool**: AWS Management Console  
**Duration**: 5 minutes  
**Focus**: Infrastructure as Code basics using the web interface

Deploy a complete VPC with public and private subnets using the CloudFormation console. This demo introduces the fundamentals of CloudFormation templates and the user-friendly console interface.

**Key Learning Outcomes**:
- Understanding CloudFormation template structure
- Using the console for stack deployment
- Working with parameters and outputs
- Monitoring stack creation progress

### 19.4 Deploy EC2 Instance Terminal
**Tool**: AWS CLI  
**Duration**: 5 minutes  
**Focus**: Command-line infrastructure deployment

Deploy an EC2 instance with security groups and a web server using AWS CLI commands. This demo demonstrates programmatic infrastructure deployment and automation capabilities.

**Key Learning Outcomes**:
- AWS CLI CloudFormation commands
- Template validation and deployment
- Stack monitoring via command line
- Resource testing and verification

### 19.5 Deploy Lambda Function Terminal
**Tool**: AWS CLI  
**Duration**: 5 minutes  
**Focus**: Serverless infrastructure deployment

Deploy a Lambda function with API Gateway integration using AWS CLI. This demo showcases serverless architecture deployment and IAM role creation.

**Key Learning Outcomes**:
- Serverless infrastructure patterns
- IAM role and policy creation
- API Gateway integration
- Function testing and monitoring

## Prerequisites

### General Requirements
- AWS account with appropriate permissions
- Basic understanding of AWS services (VPC, EC2, Lambda)
- Familiarity with YAML syntax

### Tool-Specific Requirements
- **Console demos**: Access to AWS Management Console
- **Terminal demos**: AWS CLI installed and configured

## Quick Start Guide

1. **Choose your demo** based on your learning objectives
2. **Navigate** to the specific demo directory
3. **Follow the README** instructions for step-by-step guidance
4. **Execute** the demo within the 5-minute timeframe
5. **Clean up** resources to avoid unnecessary charges

## Demo Sequence Recommendation

For optimal learning progression:

1. **Start with 19.3 (Console)** - Learn CloudFormation basics with visual feedback
2. **Progress to 19.4 (CLI/EC2)** - Apply CLI skills to familiar EC2 concepts
3. **Advance to 19.5 (CLI/Lambda)** - Explore serverless patterns and advanced integrations

## Common CloudFormation Concepts

### Template Structure
All demos use standard CloudFormation template sections:
- **AWSTemplateFormatVersion**: Template format version
- **Description**: Human-readable template description
- **Parameters**: Input values for template customization
- **Resources**: AWS resources to create
- **Outputs**: Values to return after stack creation

### Best Practices Demonstrated
- **Parameterization**: Making templates reusable
- **Resource tagging**: Organizing and tracking resources
- **Output exports**: Enabling cross-stack references
- **Dependency management**: Ensuring proper resource creation order

## Troubleshooting

### Common Issues
- **Permission errors**: Ensure adequate IAM permissions
- **Template validation**: Check YAML syntax and resource properties
- **Resource limits**: Verify account limits for the resources being created
- **Region availability**: Ensure services are available in your selected region

### Getting Help
- Check AWS CloudFormation documentation links in each demo
- Review CloudFormation stack events for detailed error messages
- Use AWS CLI `validate-template` command before deployment
- Consult AWS support or community forums for complex issues

## Cost Considerations

### Resource Costs
- **VPC Demo**: No charges for VPC, subnets, and route tables
- **EC2 Demo**: Charges apply for EC2 instance runtime (t3.micro eligible for free tier)
- **Lambda Demo**: Minimal charges for Lambda invocations and API Gateway requests

### Cost Optimization
- Use free tier eligible resources when possible
- Delete stacks immediately after demos to minimize charges
- Monitor AWS billing dashboard for usage tracking

## Advanced Topics

After completing these demos, consider exploring:
- **Stack sets**: Multi-account and multi-region deployments
- **Nested stacks**: Modular template architecture
- **Change sets**: Preview stack updates before applying
- **Custom resources**: Extending CloudFormation capabilities
- **CloudFormation Designer**: Visual template creation

## Documentation References

### Primary Resources
- [AWS CloudFormation User Guide](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/)
- [CloudFormation Template Reference](https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/)
- [AWS CLI CloudFormation Commands](https://docs.aws.amazon.com/cli/latest/reference/cloudformation/)

### Service-Specific Documentation
- [VPC CloudFormation Resources](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/quickref-ec2-vpc.html)
- [EC2 CloudFormation Resources](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/quickref-ec2.html)
- [Lambda CloudFormation Resources](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/quickref-lambda.html)

## Feedback and Contributions

These demonstrations are designed for educational purposes. If you encounter issues or have suggestions for improvements, please refer to the AWS documentation or consult with AWS support for production use cases.
