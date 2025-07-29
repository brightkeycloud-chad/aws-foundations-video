# DynamoDB Demonstrations - Instructor Guide

## Overview
This directory contains two comprehensive 5-minute demonstrations for Amazon DynamoDB, complete with scripts, documentation, and supporting materials.

## Demonstration Structure

### 16.3 - Console Demonstration
**Focus**: Visual learning through AWS Management Console  
**Duration**: 5 minutes  
**Audience**: Beginners, visual learners  

**Files**:
- `README.md` - Complete step-by-step instructions

### 16.4 - Terminal & SDK Demonstration  
**Focus**: Programmatic access via CLI and Python SDK  
**Duration**: 5-10 minutes (depending on depth)  
**Audience**: Developers, technical users  

**Files**:
- `README.md` - Complete documentation with all options
- `run_all_steps.sh` - Automated complete demonstration
- `step1_create_table.sh` - Individual step scripts
- `step2_add_items.sh`
- `step3_query_operations.sh`
- `step4_update_delete.sh`
- `step5_python_sdk_demo.py` - Python SDK examples
- `cleanup.sh` - Resource cleanup
- `demo_script.sh` - Original combined script
- `dynamodb_example.py` - Standalone Python examples

## Delivery Options

### Option 1: Quick Console Demo (5 minutes)
```bash
cd 16.3_deploy-dynamodb-table-console
# Follow README.md step by step
```
**Best for**: Introduction to DynamoDB concepts, visual learners

### Option 2: CLI/SDK Demo - Automated (5 minutes)
```bash
cd 16.4_dynamodb-table-operations-terminal-sdk
./run_all_steps.sh
```
**Best for**: Complete overview with minimal instructor intervention

### Option 3: CLI/SDK Demo - Step by Step (10 minutes)
```bash
cd 16.4_dynamodb-table-operations-terminal-sdk
./step1_create_table.sh
# Explain concepts, then continue
./step2_add_items.sh
# Continue with each step...
```
**Best for**: Detailed explanation of each concept

### Option 4: Mixed Approach (8 minutes)
1. Start with console demo (3 minutes)
2. Switch to CLI for advanced operations (5 minutes)

## Key Teaching Points

### Console Demo Highlights
- **Visual Table Creation**: Show the simplicity of DynamoDB setup
- **Schema Flexibility**: Add items with different attributes
- **Query vs Scan**: Demonstrate performance differences visually
- **NoSQL Concepts**: Explain partition/sort keys

### CLI/SDK Demo Highlights
- **Infrastructure as Code**: Show programmatic table creation
- **JSON Data Structures**: Explain DynamoDB's data format
- **Error Handling**: Demonstrate proper exception handling
- **Batch Operations**: Show efficiency improvements
- **SDK Advantages**: Compare CLI vs SDK approaches

## Pre-Demonstration Checklist

### For Console Demo
- [ ] AWS account access
- [ ] DynamoDB permissions
- [ ] Browser ready with AWS Console

### For CLI/SDK Demo
- [ ] AWS CLI installed and configured
- [ ] Python 3.x installed
- [ ] boto3 installed (`pip install boto3`)
- [ ] Scripts are executable (`chmod +x *.sh`)
- [ ] Test AWS credentials (`aws sts get-caller-identity`)

## Common Issues & Solutions

### AWS CLI Issues
**Problem**: "AWS CLI not found"  
**Solution**: Install AWS CLI or use AWS CloudShell

**Problem**: "Credentials not configured"  
**Solution**: Run `aws configure` or use IAM roles

**Problem**: "Access denied"  
**Solution**: Ensure DynamoDB permissions in IAM

### Python Issues
**Problem**: "boto3 not found"  
**Solution**: `pip install boto3`

**Problem**: "Python not found"  
**Solution**: Install Python 3.x or use `python` instead of `python3`

### Table Issues
**Problem**: "Table already exists"  
**Solution**: Run `./cleanup.sh` first

**Problem**: "Table not found"  
**Solution**: Ensure previous steps completed successfully

## Timing Guidelines

### 5-Minute Demo Structure
- **Introduction** (30 seconds): Explain DynamoDB basics
- **Table Creation** (1 minute): Show table setup
- **Data Operations** (2.5 minutes): CRUD operations
- **Query/Scan** (1 minute): Data retrieval methods
- **Wrap-up** (30 seconds): Key takeaways

### 10-Minute Extended Demo
- Add Python SDK examples (3 minutes)
- Explain best practices (2 minutes)
- Show error handling (1 minute)
- Detailed Q&A (1 minute)

## Audience Adaptation

### For Beginners
- Focus on console demonstration
- Emphasize visual elements
- Explain NoSQL concepts clearly
- Use simple, relatable examples (music library)

### For Developers
- Focus on CLI/SDK demonstration
- Show code examples
- Discuss error handling
- Explain performance considerations
- Demonstrate batch operations

### For Architects
- Discuss design patterns
- Show scaling considerations
- Explain billing models
- Cover security best practices

## Post-Demonstration Activities

### Immediate Follow-up
1. **Q&A Session**: Address specific questions
2. **Hands-on Practice**: Let students run scripts
3. **Troubleshooting**: Help with setup issues

### Extended Learning
1. **Additional Resources**: Point to AWS documentation
2. **Practice Exercises**: Suggest modifications to examples
3. **Real-world Applications**: Discuss use cases

## Cost Management

### During Demo
- Use PAY_PER_REQUEST billing (included in scripts)
- Keep data minimal (few items only)
- Clean up immediately after demo

### Cost Estimates
- **Console Demo**: ~$0.01 (minimal operations)
- **CLI/SDK Demo**: ~$0.02 (more operations)
- **Extended Demo**: ~$0.05 (with Python examples)

### Cleanup Reminders
- Always run cleanup scripts
- Verify table deletion
- Check for any remaining resources

## Troubleshooting During Live Demo

### If Scripts Fail
1. **Check Prerequisites**: AWS CLI, credentials, permissions
2. **Manual Fallback**: Use individual commands from README
3. **Console Backup**: Switch to console demo if CLI fails

### If Table Creation Fails
1. **Check Permissions**: Verify DynamoDB access
2. **Region Issues**: Ensure correct AWS region
3. **Naming Conflicts**: Use different table name

### If Python Fails
1. **Skip SDK Demo**: Focus on CLI only
2. **Use CloudShell**: If local Python issues
3. **Show Code Only**: Explain without execution

## Success Metrics

### Student Understanding
- Can explain partition vs sort keys
- Understands Query vs Scan differences
- Knows when to use DynamoDB
- Can identify NoSQL benefits

### Technical Skills
- Can create tables via console
- Can run basic CLI commands
- Understands JSON data format
- Can read Python SDK code

## Additional Resources for Students

### Documentation
- [DynamoDB Developer Guide](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/)
- [AWS CLI Reference](https://docs.aws.amazon.com/cli/latest/reference/dynamodb/)
- [Boto3 Documentation](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/dynamodb.html)

### Practice Labs
- AWS Free Tier DynamoDB limits
- DynamoDB Local for offline practice
- AWS Workshops and tutorials

### Next Steps
- Advanced DynamoDB features (GSI, LSI)
- DynamoDB Streams
- Integration with Lambda
- Performance optimization

## Feedback Collection

### During Demo
- Watch for confused expressions
- Ask clarifying questions
- Adjust pace as needed

### After Demo
- Quick survey on understanding
- Collect specific questions
- Note areas for improvement

This instructor guide ensures consistent, effective delivery of the DynamoDB demonstrations across different audiences and scenarios.
