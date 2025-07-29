# Deploy ECS Task on Fargate - Console and Terminal Demonstration

## Overview
This 5-minute demonstration shows how to deploy a containerized application on Amazon ECS using AWS Fargate launch type, combining both AWS Console and terminal operations.

## Prerequisites
- AWS Console access with ECS permissions
- AWS CLI installed and configured
- Basic understanding of containers and ECS concepts
- IAM permissions for ECS, Fargate, and VPC operations

## Demonstration Steps (5 minutes)

### Step 1: Create ECS Cluster (Console - 1 minute)
1. Open AWS ECS Console: https://console.aws.amazon.com/ecs/v2
2. Navigate to **Clusters** → **Create cluster**
3. **Cluster configuration**:
   - **Cluster name**: `fargate-demo-cluster`
   - Leave other settings as default
4. Click **Create**

### Step 2: Create Task Definition (Console - 2 minutes)
1. Navigate to **Task Definitions** → **Create new Task Definition**
2. Choose **Create new revision with JSON**
3. Paste the following task definition:

```json
{
    "family": "sample-fargate-demo", 
    "networkMode": "awsvpc", 
    "containerDefinitions": [
        {
            "name": "fargate-app", 
            "image": "public.ecr.aws/docker/library/httpd:latest", 
            "portMappings": [
                {
                    "containerPort": 80, 
                    "hostPort": 80, 
                    "protocol": "tcp"
                }
            ], 
            "essential": true, 
            "entryPoint": [
                "sh",
                "-c"
            ], 
            "command": [
                "/bin/sh -c \"echo '<html><head><title>ECS Fargate Demo</title><style>body {margin-top: 40px; background-color: #333;}</style></head><body><div style=color:white;text-align:center><h1>ECS Fargate Demo</h1><h2>Success!</h2><p>Your application is running on Fargate!</p></div></body></html>' > /usr/local/apache2/htdocs/index.html && httpd-foreground\""
            ]
        }
    ], 
    "requiresCompatibilities": [
        "FARGATE"
    ], 
    "cpu": "256", 
    "memory": "512"
}
```

4. Click **Create**

### Step 3: Create and Deploy Service (Console - 1.5 minutes)
1. Navigate to **Clusters** → Select `fargate-demo-cluster`
2. **Services** tab → **Create**
3. **Deployment configuration**:
   - **Task definition**: Select `sample-fargate-demo`
   - **Service name**: `fargate-demo-service`
   - **Desired tasks**: `1`
4. **Networking**: 
   - Use default VPC and subnets
   - Create new security group or select existing one with port 80 open
5. Click **Create**

### Step 4: Verify Deployment (Terminal - 0.5 minutes)
```bash
# List running tasks
aws ecs list-tasks \
    --cluster fargate-demo-cluster \
    --region us-west-2

# Get task details including public IP
aws ecs describe-tasks \
    --cluster fargate-demo-cluster \
    --tasks <task-arn> \
    --region us-west-2
```

### Step 5: Access Application (Console)
1. In ECS Console, navigate to your cluster
2. Click on the service → **Tasks** tab
3. Click on the running task
4. In **Configuration** section, find **Public IP**
5. Click **Open address** to view the application

## Key Learning Points
- Fargate eliminates the need to manage EC2 instances
- Task definitions define container specifications and resource requirements
- Services ensure desired number of tasks are running
- `awsvpc` network mode provides each task with its own ENI
- Security groups control network access to Fargate tasks

## Monitoring and Troubleshooting
```bash
# Check service status
aws ecs describe-services \
    --cluster fargate-demo-cluster \
    --services fargate-demo-service \
    --region us-west-2

# View service events
aws ecs describe-services \
    --cluster fargate-demo-cluster \
    --services fargate-demo-service \
    --region us-west-2 \
    --query 'services[0].events'

# Check task logs (if CloudWatch logging is enabled)
aws logs describe-log-groups --log-group-name-prefix /ecs/sample-fargate-demo
```

## Cleanup
```bash
# Delete the service
aws ecs delete-service \
    --cluster fargate-demo-cluster \
    --service fargate-demo-service \
    --force \
    --region us-west-2

# Delete the cluster (via Console)
# Navigate to Clusters → Select cluster → Delete

# Deregister task definition (via Console)
# Navigate to Task Definitions → Select family → Deregister
```

## Common Issues and Solutions
- **Task fails to start**: Check security group allows outbound internet access for image pulling
- **Cannot access application**: Verify security group has inbound rule for port 80
- **Service stuck in PENDING**: Check subnet has internet gateway for public IP assignment
- **Task stops immediately**: Review task definition for configuration errors

## Documentation References
- [Learn how to create an Amazon ECS Linux task for the Fargate launch type](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/getting-started-fargate.html)
- [AWS Fargate for Amazon ECS](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html)
- [Amazon ECS task definitions](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html)
- [Amazon ECS examples using AWS CLI](https://docs.aws.amazon.com/cli/v1/userguide/cli_ecs_code_examples.html)
