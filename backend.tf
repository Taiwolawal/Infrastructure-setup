terraform {
  backend "s3" {
    bucket = "eks-demo-prod-bucket"
    key    = "terraform/dev-blue.tfstate"
    region = "us-east-1"
  }
}

# name                           = var.name
#   cidr                           = var.cidr
#   azs                            = var.azs
#   private_subnets                = var.private_subnets
#   public_subnets                 = var.public_subnets
#   create_database_subnet_group   = var.create_database_subnet_group
#   database_subnets               = var.database_subnets
#   database_subnet_group_name     = var.database_subnet_group_name
#   manage_default_route_table     = var.manage_default_route_table
#   default_route_table_tags       = var.default_route_table_tags
#   manage_default_security_group  = var.manage_default_security_group
#   default_security_group_tags    = var.default_security_group_tags
#   enable_dns_hostnames           = var.enable_dns_hostnames
#   enable_dns_support             = var.enable_dns_support
#   enable_classiclink_dns_support = var.enable_classiclink_dns_support
#   enable_nat_gateway             = var.enable_nat_gateway
#   single_nat_gateway             = var.single_nat_gateway
#   tags                           = var.tags