# output "security_group_id" {
#   value = [module.sg-rds.security_group_id]
# }

output "vpc_owner_id" {
  value = [module.vpc.vpc_owner_id]
}

output "vpc_id" {
  value = [module.vpc.vpc_id]
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

# output "admin_iam_user_name" {
#   value = module.admin_user.iam_user_name
# }

# output "developer_iam_user_name" {
#   value = module.developer_user.iam_user_name
# }