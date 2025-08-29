output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.demo_function.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.demo_function.arn
}

output "codedeploy_app_name" {
  description = "Name of the CodeDeploy application"
  value       = aws_codedeploy_app.lambda_app.name
}

output "codedeploy_deployment_group" {
  description = "Name of the CodeDeploy deployment group"
  value       = aws_codedeploy_deployment_group.lambda_deployment_group.deployment_group_name
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for deployment artifacts"
  value       = aws_s3_bucket.deployment_artifacts.bucket
}
