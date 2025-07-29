# Create ECR Repository - Terminal Demonstration

## Overview
This 5-minute demonstration shows how to create an Amazon Elastic Container Registry (ECR) repository using the AWS CLI terminal, build a simple Docker image, and push it to the repository.

## Prerequisites
- AWS CLI installed and configured with appropriate permissions
- Docker installed and running
- IAM permissions for ECR operations

## Demonstration Steps (5 minutes)

### Step 1: Create ECR Repository (1 minute)
```bash
# Create a new ECR repository
aws ecr create-repository \
    --repository-name hello-world-demo \
    --region us-east-1

# List repositories to verify creation
aws ecr describe-repositories --region us-east-1
```

### Step 2: Authenticate Docker to ECR (1 minute)
```bash
# Get authentication token and authenticate Docker
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
```

### Step 3: Create Simple Docker Image (2 minutes)
```bash
# Create a simple Dockerfile
cat > Dockerfile << 'EOF'
FROM public.ecr.aws/amazonlinux/amazonlinux:latest

# Install dependencies
RUN yum update -y && \
    yum install -y httpd

# Install apache and write hello world message
RUN echo 'Hello World from ECR Demo!' > /var/www/html/index.html

# Configure apache
RUN echo 'mkdir -p /var/run/httpd' >> /root/run_apache.sh && \
    echo 'mkdir -p /var/lock/httpd' >> /root/run_apache.sh && \
    echo '/usr/sbin/httpd -D FOREGROUND' >> /root/run_apache.sh && \
    chmod 755 /root/run_apache.sh

EXPOSE 80

CMD /root/run_apache.sh
EOF

# Build the Docker image
docker build -t hello-world-demo .

# Verify the image was created
docker images --filter reference=hello-world-demo
```

### Step 4: Tag and Push Image to ECR (1 minute)
```bash
# Tag the image for ECR
docker tag hello-world-demo:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/hello-world-demo:latest

# Push the image to ECR
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/hello-world-demo:latest

# Verify the image was pushed
aws ecr list-images --repository-name hello-world-demo --region us-east-1
```

## Key Learning Points
- ECR repositories store Docker container images securely
- Authentication is required before pushing images to ECR
- Images must be tagged with the ECR repository URI format
- ECR integrates seamlessly with other AWS container services

## Cleanup (Optional)
```bash
# Delete the ECR repository and all images
aws ecr delete-repository \
    --repository-name hello-world-demo \
    --region us-east-1 \
    --force

# Remove local Docker image
docker rmi hello-world-demo:latest
docker rmi <account-id>.dkr.ecr.us-east-1.amazonaws.com/hello-world-demo:latest
```

## Troubleshooting
- **Authentication Error**: Ensure AWS CLI is configured with proper credentials
- **Permission Denied**: Verify IAM user has ECR permissions (ecr:CreateRepository, ecr:GetAuthorizationToken, etc.)
- **Docker Not Running**: Start Docker service before attempting to build or push images

## Documentation References
- [Moving an image through its lifecycle in Amazon ECR](https://docs.aws.amazon.com/AmazonECR/latest/userguide/getting-started-cli.html)
- [Amazon ECR examples using AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli_ecr_code_examples.html)
- [create-repository — AWS CLI Command Reference](https://docs.aws.amazon.com/cli/latest/reference/ecr/create-repository.html)
