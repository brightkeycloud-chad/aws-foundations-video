# Use AWS Lambda Python base image for x86_64 architecture
FROM --platform=linux/amd64 public.ecr.aws/lambda/python:3.13

# Copy requirements and install dependencies
COPY requirements.txt ${LAMBDA_TASK_ROOT}

# Install Python dependencies with options optimized for Lambda
RUN pip install --no-cache-dir --only-binary=all -r requirements.txt

# Copy function code
COPY app.py ${LAMBDA_TASK_ROOT}

# Set the CMD to your handler
CMD [ "app.lambda_handler" ]
