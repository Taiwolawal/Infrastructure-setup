data "aws_caller_identity" "current" {}

module "ecr" {
  source                   = "terraform-aws-modules/ecr/aws"
  version                  = "1.5.1"
  repository_name          = var.repository_name
  repository_type          = var.repository_type
  create_repository_policy = var.create_repository_policy
  create_lifecycle_policy  = var.create_lifecycle_policy
  repository_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowEKSAccess",
        Effect = "Allow",
        Principal = {
          "AWS" : module.eks_admins_iam_role.iam_role_arn
        },
        Action = [
          "ecr:ReplicateImage",
          "ecr:DescribeImageScanFindings",
          "ecr:StartImageScan",
          "ecr:GetDownloadUrlForLayer",
          "ecr:UploadLayerPart",
          "ecr:BatchDeleteImage",
          "ecr:ListImages",
          "ecr:PutImage",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeImages",
          "ecr:InitiateLayerUpload",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetRepositoryPolicy",
          "ecr:GetLifecyclePolicy",
          "ecr:DescribeRegistry",
          "ecr:DescribePullThroughCacheRules",
          "ecr:GetAuthorizationToken"
        ],
        Resource = "*"
      }
    ]
  })
  repository_read_write_access_arns = [data.aws_caller_identity.current.arn]
  tags                              = var.tags
}