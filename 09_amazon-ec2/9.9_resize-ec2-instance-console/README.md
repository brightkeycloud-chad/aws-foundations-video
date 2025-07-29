# Resize EC2 Instance - Console Demonstration

## Overview
This 5-minute demonstration shows how to change the instance type of an Amazon EC2 instance using the AWS Management Console. This process allows you to scale your compute resources up or down based on changing requirements.

## Duration
5 minutes

## Prerequisites
- Running EC2 instance that you want to resize
- EC2 instance must be EBS-backed (not instance-store)
- Appropriate permissions to stop/start and modify EC2 instances
- Understanding that the instance will experience downtime during the process

## Learning Objectives
By the end of this demonstration, you will:
- Understand when and why to resize EC2 instances
- Learn the step-by-step process to change instance types
- Know the limitations and considerations for resizing
- Understand the impact on instance data and configuration

## Step-by-Step Instructions

### Step 1: Prepare for Resize (1 minute)
1. Navigate to **EC2 Console** → **Instances**
2. Select the instance you want to resize
3. Note the current instance type in the **Details** tab
4. **Important**: Inform users that the instance will be temporarily unavailable
5. Consider creating a snapshot of EBS volumes as a backup (optional but recommended)

### Step 2: Stop the Instance (1.5 minutes)
1. With the instance selected, click **Instance state** → **Stop instance**
2. In the confirmation dialog, click **Stop**
3. Wait for the instance state to change from:
   - **Running** → **Stopping** → **Stopped**
4. This may take 1-2 minutes depending on the instance
5. **Note**: Instance-store backed instances cannot be stopped (only terminated)

### Step 3: Change Instance Type (1.5 minutes)
1. With the stopped instance selected, click **Actions** → **Instance settings** → **Change instance type**
2. The **Change instance type** dialog opens
3. **Current instance type** shows the existing type (e.g., t3.micro)
4. **New instance type** dropdown shows available options:
   - For demo: Change from `t3.micro` to `t3.small`
   - Note compatibility warnings if any appear
5. Click **Apply** to confirm the change

### Step 4: Start the Instance (1 minute)
1. With the instance still selected, click **Instance state** → **Start instance**
2. Click **Start** in the confirmation dialog
3. Wait for the instance state to change:
   - **Stopped** → **Pending** → **Running**
4. The instance will get a new public IP address (if using dynamic IPs)
5. Verify the new instance type in the **Details** tab

## Key Concepts Explained

### When to Resize Instances
- **Scale up**: When you need more CPU, memory, or network performance
- **Scale down**: To reduce costs when resources are underutilized
- **Change families**: Switch between general purpose, compute optimized, etc.
- **Seasonal demands**: Adjust for predictable traffic patterns

### Instance Type Families
- **General Purpose**: T3, T4g, M5, M6i (balanced CPU, memory, networking)
- **Compute Optimized**: C5, C6i (high-performance processors)
- **Memory Optimized**: R5, R6i, X1e (high memory-to-CPU ratio)
- **Storage Optimized**: I3, D2 (high sequential read/write to local storage)

### Compatibility Considerations
- **Architecture**: x86 vs ARM (Graviton) processors
- **Virtualization**: HVM vs PV (most modern instances use HVM)
- **Network**: Enhanced networking capabilities
- **Storage**: EBS optimization support

## Limitations and Considerations

### Technical Limitations
- Instance must be EBS-backed (not instance-store)
- Some older instance types may not support all features
- Network performance may change between instance types
- Some instance types are not available in all Availability Zones

### Data and Configuration Impact
- **EBS volumes**: Remain attached and unchanged
- **Instance store**: Lost during stop/start (if present)
- **Public IP**: Changes unless using Elastic IP
- **Private IP**: Remains the same within VPC
- **Security groups**: Remain attached
- **IAM roles**: Remain attached

### Downtime Considerations
- Instance is unavailable during stop/start process
- Typically 2-5 minutes total downtime
- Applications need to handle the interruption
- Consider using Auto Scaling for zero-downtime scaling

## Verification Steps
1. **Instance type**: Verify new type in EC2 console Details tab
2. **Performance**: Monitor CPU, memory usage after resize
3. **Applications**: Test that applications start correctly
4. **Connectivity**: Verify network connectivity and new public IP
5. **Logs**: Check system logs for any issues during restart

## Cost Impact Analysis

### Before Resizing
- Check current instance pricing
- Review utilization metrics in CloudWatch
- Consider Reserved Instance implications

### After Resizing
- New hourly rate takes effect immediately
- Monitor costs in AWS Cost Explorer
- Adjust Reserved Instances if needed

## Monitoring and Optimization

### CloudWatch Metrics to Monitor
- **CPU Utilization**: Verify the new instance type meets requirements
- **Memory Utilization**: Check if memory increase was effective
- **Network Performance**: Monitor network throughput changes
- **Disk I/O**: Verify storage performance is adequate

### Right-Sizing Recommendations
- Use AWS Compute Optimizer for recommendations
- Monitor for at least 2 weeks after resizing
- Consider Auto Scaling for dynamic workloads

## Alternative Scaling Approaches

### Auto Scaling Groups
- Automatically adjust capacity based on demand
- No downtime for individual instances
- Better for stateless applications

### Load Balancing
- Distribute traffic across multiple instances
- Add/remove instances without affecting users
- Horizontal scaling vs vertical scaling

## Troubleshooting Common Issues

### Instance Won't Stop
- Check for stuck processes or applications
- Force stop if necessary (may cause data loss)
- Review system logs for errors

### Instance Type Not Available
- Try different Availability Zone
- Check if instance type exists in your region
- Consider alternative instance types with similar specs

### Application Issues After Resize
- Check application logs for startup errors
- Verify memory/CPU requirements are met
- Test application functionality thoroughly

## Best Practices
- **Plan for downtime**: Schedule during maintenance windows
- **Backup data**: Create EBS snapshots before major changes
- **Test thoroughly**: Verify applications work with new instance type
- **Monitor performance**: Watch metrics after resizing
- **Document changes**: Keep records of instance modifications

## Next Steps
- Set up CloudWatch alarms for the new instance type
- Review and adjust monitoring thresholds
- Consider implementing Auto Scaling for future scaling needs
- Evaluate cost optimization opportunities

## Citations and Documentation

1. **Change the instance type** - Amazon EC2 User Guide  
   https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-resize.html

2. **How EC2 instance stop and start works** - Amazon EC2 User Guide  
   https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/how-ec2-instance-stop-start-works.html

3. **Amazon EC2 instance types** - Amazon EC2 User Guide  
   https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html

4. **Change an Amazon EC2 instance type with a bash script** - AWS CLI User Guide  
   https://docs.aws.amazon.com/cli/latest/userguide/cli-services-ec2-instance-type-script.html

## Additional Resources
- AWS Compute Optimizer: https://aws.amazon.com/compute-optimizer/
- EC2 Instance Types: https://aws.amazon.com/ec2/instance-types/
- AWS Pricing Calculator: https://calculator.aws/
