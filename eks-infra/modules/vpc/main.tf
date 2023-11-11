module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  # VPC Basic Details
  name            = var.vpc_name
  cidr            = var.cidr
  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  # Database Subnet Setup  
  # create_database_subnet_group = var.create_database_subnet_group
  # database_subnets             = var.database_subnets
  # database_subnet_group_name   = var.database_subnet_group_name

  # VPC DNS Parameters
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  # VPC DNS Parameters
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = var.tags
}