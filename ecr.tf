# Terraform configuration for AWS ECR repository
resource "aws_ecr_repository" "app" {
  name                 = var.ECR_REPO_NAME
  image_tag_mutability = "IMMUTABLE"

  # Enforce vulnerability scanning on push
  image_scanning_configuration {
    scan_on_push = true
  }

  # Enable encryption at rest
  encryption_configuration {
    encryption_type = "KMS"
  }

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

# This lifecycle policy will automatically expire untagged images older than 30 days, helping to manage storage costs and keep the repository clean.
resource "aws_ecr_lifecycle_policy" "cleanup" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Expire untagged images older than 30 days"
      selection    = {
        tagStatus   = "untagged"
        countType   = "sinceImagePushed"
        countUnit   = "days"
        countNumber = 30
      }
      action = { type = "expire" }
    }]
  })
}

