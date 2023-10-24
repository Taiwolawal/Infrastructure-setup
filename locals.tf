locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.creds.secret_string
  )

  repository_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowECRAccess",
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

  aws_auth_roles = [
    {
      rolearn  = module.eks_admins_iam_role.iam_role_arn
      username = module.eks_admins_iam_role.iam_role_name
      groups   = ["system:masters"]
    },
  ]

   iam_role_additional_policies = {
    FullECRAccessPolicy = aws_iam_policy.ecr_access_for_worker_node.arn
    OtherAccessPolicy   = aws_iam_policy.other_ecr_access_for_worker_node.arn
  }

  eks_managed_node_group_defaults = {
    iam_role_additional_policies = {
      FullECRAccessPolicy = aws_iam_policy.ecr_access_for_worker_node.arn
      OtherAccessPolicy   = aws_iam_policy.other_ecr_access_for_worker_node.arn
    }
  }


}