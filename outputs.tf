# Output the Role ARN to pass to your CI/CD runner
output "role_arn" {
  value       = aws_iam_role.ecr_push_role.arn
  description = "ARN of the IAM role to assume during build"
}

output "ecr_repository_arn" {
  value       = aws_ecr_repository.app.arn
  description = "The ARN of the ECR repository"
  
}

