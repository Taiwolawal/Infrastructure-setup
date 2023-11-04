output "vpc_owner_id" {
  value = module.vpc.vpc_owner_id
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
    value = module.vpc.private_subnets
}