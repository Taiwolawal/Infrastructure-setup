data "aws_secretsmanager_secret_version" "creds" {
  secret_id = "db-creds-v2"
}

locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.creds.secret_string
  )
}


module "rds" {
  source               = "terraform-aws-modules/rds/aws"
  version              = "6.1.1"
  identifier           = var.identifier
  create_db_instance   = var.create_db_instance
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  db_subnet_group_name = var.database_subnet_group_name
  allocated_storage    = var.allocated_storage
  vpc_security_group_ids = [module.sg-rds.security_group_id]
  db_name              = var.db_name
  username             = local.db_creds.username
  password             = local.db_creds.password
  port                 = var.port
  subnet_ids           = var.database_subnets
  family               = var.family
  major_engine_version = var.major_engine_version
  deletion_protection  = var.deletion_protection
  tags                 = var.tags
}