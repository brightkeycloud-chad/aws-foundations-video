# Demo 13.4: Mount EFS File System Using Terminal

## Overview
This 5-minute demonstration shows how to mount an Amazon EFS file system to an EC2 instance using the terminal. You'll install the EFS utilities, create a mount point, and mount the file system using the EFS mount helper.

## Prerequisites
- Running EC2 instance (Amazon Linux 2, Ubuntu, or other supported Linux distribution)
- Existing EFS file system (created in previous demo)
- Security group allowing NFS traffic (port 2049) between EC2 and EFS
- SSH access to the EC2 instance
- File system ID from the EFS console

## Demonstration Steps

### Step 1: Connect to EC2 Instance (30 seconds)
```bash
# Connect via SSH (replace with your instance details)
ssh -i your-key.pem ec2-user@your-instance-ip
```

### Step 2: Install Amazon EFS Utilities (1 minute)
```bash
# For Amazon Linux 2/Amazon Linux 2023
sudo yum update -y
sudo yum install -y amazon-efs-utils

# For Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y amazon-efs-utils

# For RHEL/CentOS
sudo yum install -y amazon-efs-utils

# Verify installation
mount.efs --version
```

### Step 3: Create Mount Point Directory (30 seconds)
```bash
# Create a directory to serve as the mount point
sudo mkdir -p /mnt/efs
sudo mkdir -p /home/ec2-user/efs-mount-point

# Set appropriate permissions
sudo chown ec2-user:ec2-user /home/ec2-user/efs-mount-point
```

### Step 4: Mount the EFS File System (1.5 minutes)
```bash
# Method 1: Using File System ID (recommended)
sudo mount -t efs fs-xxxxxxxxx:/ /mnt/efs

# Method 2: Using DNS name
sudo mount -t efs your-file-system-id.efs.region.amazonaws.com:/ /mnt/efs

# Method 3: With encryption in transit
sudo mount -t efs -o tls fs-xxxxxxxxx:/ /mnt/efs

# Method 4: Using IAM authorization
sudo mount -t efs -o tls,iam fs-xxxxxxxxx:/ /mnt/efs

# Verify the mount
df -h
mount | grep efs
```

### Step 5: Test File System Operations (1.5 minutes)
```bash
# Change to the mounted directory
cd /mnt/efs

# Create a test file
echo "Hello from EFS!" | sudo tee test-file.txt

# Create a directory
sudo mkdir test-directory

# List contents
ls -la

# Check file system usage
df -h /mnt/efs

# Test from another location
echo "Testing EFS write access" | sudo tee /mnt/efs/test-directory/write-test.txt

# Verify file persistence
cat /mnt/efs/test-file.txt
cat /mnt/efs/test-directory/write-test.txt
```

### Step 6: Configure Automatic Mounting (Optional - 30 seconds)
```bash
# Edit fstab for automatic mounting on boot
sudo cp /etc/fstab /etc/fstab.backup

# Add entry to fstab (replace fs-xxxxxxxxx with your file system ID)
echo "fs-xxxxxxxxx.efs.region.amazonaws.com:/ /mnt/efs efs defaults,_netdev" | sudo tee -a /etc/fstab

# Test the fstab entry
sudo umount /mnt/efs
sudo mount -a
df -h | grep efs
```

## Mount Options Explained

### Basic Mount Options
- `tls`: Enables encryption in transit
- `iam`: Uses IAM for authorization
- `accesspoint`: Mounts via an access point
- `regional`: Uses regional mount targets (default)

### Performance Options
- `rsize=1048576`: Read buffer size (1MB)
- `wsize=1048576`: Write buffer size (1MB)
- `hard`: Hard mount (recommended)
- `intr`: Allows interruption of file operations

### Example with Performance Tuning
```bash
sudo mount -t efs -o tls,rsize=1048576,wsize=1048576,hard,intr fs-xxxxxxxxx:/ /mnt/efs
```

## Troubleshooting Common Issues

### Mount Fails with "Connection Timed Out"
```bash
# Check security group rules
# Ensure port 2049 (NFS) is open between EC2 and EFS

# Test connectivity
telnet fs-xxxxxxxxx.efs.region.amazonaws.com 2049
```

### Mount Fails with "No Such Device"
```bash
# Install EFS utilities if not already installed
sudo yum install -y amazon-efs-utils

# Check if the file system exists and is available
aws efs describe-file-systems --file-system-id fs-xxxxxxxxx
```

### Permission Denied Errors
```bash
# Check mount point permissions
ls -la /mnt/efs

# Change ownership if needed
sudo chown ec2-user:ec2-user /mnt/efs
```

## Performance Testing

### Basic Performance Test
```bash
# Create a test file to measure write performance
time dd if=/dev/zero of=/mnt/efs/testfile bs=1M count=100

# Test read performance
time dd if=/mnt/efs/testfile of=/dev/null bs=1M

# Clean up test file
rm /mnt/efs/testfile
```

### Monitor EFS Performance
```bash
# Install CloudWatch agent for detailed metrics
sudo yum install -y amazon-cloudwatch-agent

# View mount statistics
cat /proc/mounts | grep efs
nfsstat -m
```

## Security Best Practices

### Use Encryption in Transit
```bash
# Always use TLS for sensitive data
sudo mount -t efs -o tls fs-xxxxxxxxx:/ /mnt/efs
```

### Use IAM Authorization
```bash
# Mount with IAM for fine-grained access control
sudo mount -t efs -o tls,iam fs-xxxxxxxxx:/ /mnt/efs
```

### Use Access Points
```bash
# Mount via access point for additional security
sudo mount -t efs -o tls,accesspoint=fsap-xxxxxxxxx fs-xxxxxxxxx:/ /mnt/efs
```

## Cleanup Instructions
```bash
# Unmount the file system
sudo umount /mnt/efs

# Remove fstab entry if added
sudo sed -i '/efs/d' /etc/fstab

# Remove mount point directory
sudo rmdir /mnt/efs
```

## Key Commands Summary
```bash
# Install EFS utilities
sudo yum install -y amazon-efs-utils

# Create mount point
sudo mkdir /mnt/efs

# Mount file system
sudo mount -t efs fs-xxxxxxxxx:/ /mnt/efs

# Verify mount
df -h | grep efs

# Unmount
sudo umount /mnt/efs
```

## Documentation References
- [Mounting EFS file systems](https://docs.aws.amazon.com/efs/latest/ug/mounting-fs.html)
- [Mounting EFS file systems using the EFS mount helper](https://docs.aws.amazon.com/efs/latest/ug/efs-mount-helper.html)
- [Installing the Amazon EFS client](https://docs.aws.amazon.com/efs/latest/ug/using-amazon-efs-utils.html)
- [Troubleshooting mount issues](https://docs.aws.amazon.com/efs/latest/ug/troubleshooting-efs-mounting.html)
- [Tutorial: Create an EFS file system and mount it on an EC2 instance using the AWS CLI](https://docs.aws.amazon.com/efs/latest/ug/wt1-getting-started.html)
