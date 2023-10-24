data "aws_caller_identity" "current" {}

module "ecr" {
  source                   = "terraform-aws-modules/ecr/aws"
  version                  = "1.5.1"
  repository_name          = var.repository_name
  repository_type          = var.repository_type
  create_lifecycle_policy  = var.create_lifecycle_policy
  repository_read_write_access_arns = [data.aws_caller_identity.current.arn]
  tags                              = var.tags
}