module "vpc" {
  source          = "./modules/vpc"
  vpc_name        = var.vpc_name
  cidr            = var.cidr
  azs             = ["${var.region}a", "${var.region}b"]
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  # create_database_subnet_group = var.create_database_subnet_group
  # database_subnets             = var.database_subnets
  # database_subnet_group_name   = var.database_subnet_group_name
  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags                 = var.tags
}

# module "rds" {
#   source                     = "./modules/rds"
#   identifier                 = var.identifier
#   create_db_instance         = var.create_db_instance
#   engine                     = var.engine
#   engine_version             = var.engine_version
#   instance_class             = var.instance_class
#   database_subnet_group_name = var.database_subnet_group_name
#   allocated_storage          = var.allocated_storage
#   vpc_security_group_ids     = module.sg-rds.security_group_id
#   db_name                    = var.db_name
#   username                   = local.db_creds.username
#   password                   = local.db_creds.password
#   port                       = var.port
#   database_subnets           = var.database_subnets
#   family                     = var.family
#   major_engine_version       = var.major_engine_version
#   deletion_protection        = var.deletion_protection
#   tags                       = var.tags
# }

module "ecr" {
  source                  = "./modules/ecr"
  repository_name         = var.repository_name
  repository_type         = var.repository_type
  create_lifecycle_policy = var.create_lifecycle_policy
  tags                    = var.tags
}

# module "sg-rds" {
#   source                   = "./modules/sg"
#   vpc_id                   = module.vpc.vpc_id
#   create                   = var.create
#   ingress_cidr_blocks      = var.ingress_cidr_blocks
#   ingress_rules            = var.ingress_rules
#   ingress_with_cidr_blocks = var.ingress_with_cidr_blocks
#   egress_with_cidr_blocks  = var.egress_with_cidr_blocks
#   egress_cidr_blocks       = var.egress_cidr_blocks
#   egress_rules             = var.egress_rules
# }

module "eks" {
  source                          = "./modules/eks"
  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_addons                  = var.cluster_addons
  vpc_id                          = module.vpc.vpc_id
  enable_irsa                     = var.enable_irsa
  subnet_ids                      = var.private_subnets
  eks_managed_node_groups         = var.eks_managed_node_groups
  manage_aws_auth_configmap       = var.manage_aws_auth_configmap
  aws_auth_roles                  = local.aws_auth_roles
  iam_role_additional_policies    = local.iam_role_additional_policies
  eks_managed_node_group_defaults = local.iam_role_additional_policies
  tags                            = var.tags
}
