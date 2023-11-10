output "security_group_id" {
  value = [module.sg-rds.security_group_id]
}

output "vpc_owner_id" {
  value = [module.vpc.vpc_owner_id]
}

output "vpc_id" {
  value = [module.vpc.vpc_id]
}


# output "admin_user" {
#   value = module.eks_admins_iam_group.username
# }

# output "admin_iam_user_name" {
#   value = module.eks_admins_iam_group.username.arn
# }

# output "developer_iam_user_name" {
#   value = module.developer_user.iam_user_name
# }