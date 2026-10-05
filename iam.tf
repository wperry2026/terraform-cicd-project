#---------------------------------------------
# 1. Reference your existing OIDC Provider
#---------------------------------------------
data "aws_iam_openid_connect_provider" "oidc" {
  arn = "arn:aws:iam::096966628706:oidc-provider/token.actions.githubusercontent.com"
}

#---------------------------------------------
# 2. Define the Assume Role Trust Policy
#---------------------------------------------
data "aws_iam_policy_document" "ecr_oidc_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.oidc.arn]
    }

    # Restrict assumption to a specific repository / environment / branch
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      # Format: repo:<org>/<repo>:ref:refs/heads/<branch> or repo:<org>/<repo>:*
      values   = ["repo:wperry2026@267149410/python-todoapp-cicd-project@1380600875:ref:refs/heads/main","repo:wperry2026@267149410/python-todoapp-cicd-project@1380600875:ref:refs/heads/dev"]
    }
  }
}

#---------------------------------------------
# 3. Define the Permissions Policy to push to ECR
#---------------------------------------------
data "aws_iam_policy_document" "ecr_push_permissions" {
  # Step 1: ECR Authentication (Required globally before pulling/pushing)
  statement {
    sid       = "ECRAuthToken"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  # Step 2: Push capabilities restricted to target repository
  statement {
    sid    = "ECRPushAccess"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]
    # Restrict access to a specific ECR repository ARN or set to ["*"] if pushing to multiple
    # Direct reference replaces hardcoded ARN and handles execution order automatically
    resources = [aws_ecr_repository.app_repo.arn]
  }
}

#---------------------------------------------
# 4. Create the IAM Policy
#---------------------------------------------
resource "aws_iam_policy" "ecr_push" {
  name        = "ecr-push-policy"
  description = "Allows pushing Docker images to Amazon ECR"
  policy      = data.aws_iam_policy_document.ecr_push_permissions.json
}

#----------------------------------------------
# 5. Create the IAM Role
#----------------------------------------------
resource "aws_iam_role" "ecr_push_role" {
  name               = "github-actions-ecr-cicd-role"
  assume_role_policy = data.aws_iam_policy_document.ecr_oidc_trust.json
}

#---------------------------------------------
# 6. Attach the Permissions Policy to the Role
#---------------------------------------------
resource "aws_iam_role_policy_attachment" "attach_ecr_push" {
  role       = aws_iam_role.ecr_push_role.name
  policy_arn = aws_iam_policy.ecr_push.arn
}

#---------------------------------------------
# 7. IAM Execution Role for ECS Agent
#---------------------------------------------
resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

