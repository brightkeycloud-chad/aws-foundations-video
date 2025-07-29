# Deploy RDS Database Console Demonstration

## Overview
This 5-minute demonstration shows how to create an Amazon RDS database instance using the AWS Management Console. You'll learn the essential steps to deploy a MySQL database with proper security configurations.

## Prerequisites
- AWS account with appropriate permissions
- Access to AWS Management Console
- Basic understanding of database concepts

## Demonstration Steps

### Step 1: Access RDS Console (30 seconds)
1. Sign in to the AWS Management Console
2. Navigate to **Services** → **Database** → **RDS**
3. Click **Create database** button

### Step 2: Choose Database Engine (45 seconds)
1. Select **Standard create** for full configuration options
2. Choose **MySQL** as the engine type
3. Select the latest **MySQL 8.0** version
4. Choose **Free tier** template (for demonstration purposes)

### Step 3: Configure Database Settings (90 seconds)
1. **DB instance identifier**: Enter `demo-mysql-db`
2. **Master username**: Keep default `admin`
3. **Master password**: Choose **Auto generate a password** or set a custom password
4. **DB instance class**: Select `db.t3.micro` (free tier eligible)
5. **Storage**: Keep default 20 GiB General Purpose SSD

### Step 4: Configure Connectivity (90 seconds)
1. **VPC**: Use default VPC
2. **Subnet group**: Use default subnet group
3. **Public access**: Select **No** (recommended for security)
4. **VPC security group**: Create new security group named `demo-rds-sg`
5. **Availability Zone**: No preference
6. **Database port**: Keep default 3306

### Step 5: Additional Configuration (60 seconds)
1. **Initial database name**: Enter `sampledb`
2. **Backup retention period**: 7 days
3. **Backup window**: No preference
4. **Maintenance window**: No preference
5. **Enable Enhanced monitoring**: Unchecked (for demo)
6. **Enable Performance Insights**: Unchecked (for demo)

### Step 6: Create Database (45 seconds)
1. Review all settings in the summary
2. Click **Create database**
3. Note the creation process begins
4. Explain that creation takes 5-10 minutes typically

### Step 7: View Database Details (30 seconds)
1. Click on the database identifier to view details
2. Show the **Connectivity & security** tab
3. Point out the endpoint URL (will be available after creation)
4. Explain security group configuration

## Key Learning Points
- RDS simplifies database administration
- Security groups control database access
- Automated backups are enabled by default
- Multi-AZ deployment provides high availability
- Free tier options available for learning

## Security Best Practices Highlighted
- Database placed in private subnet (no public access)
- Security groups restrict network access
- Master password should be strong and secure
- Regular automated backups enabled

## Cost Considerations
- Free tier: 750 hours of db.t3.micro usage per month
- 20 GB of storage included
- Backup storage up to database size is free

## Next Steps
After creation completes:
- Connect from EC2 instance in same VPC
- Create database tables and sample data
- Configure monitoring and alerts
- Set up read replicas for scaling

## Troubleshooting Tips
- If creation fails, check IAM permissions
- Ensure VPC has proper subnet configuration
- Verify security group rules for connectivity
- Check AWS service limits for your account

---

## Documentation References

1. **Creating an Amazon RDS DB instance**  
   https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_CreateDBInstance.html

2. **Amazon RDS Getting Started Guide**  
   https://docs.aws.amazon.com/AmazonRDS/latest/gettingstartedguide/creating.html

3. **What is Amazon Relational Database Service (Amazon RDS)?**  
   https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Welcome.html

4. **Settings for DB instances**  
   https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_CreateDBInstance.Settings.html

5. **Amazon RDS Security**  
   https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.html
