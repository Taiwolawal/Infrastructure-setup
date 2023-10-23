# Infrastructure-Setup

The task of this project is to set up Kubernetes cluster in AWS, Elastic container registry, and MySQL
Database using Terraform.


Terraform will be used to provision all the resources required for the projects. We need to set up providers and statefile needed, they are:

- Provider: plugins that enable interactions with different cloud providers, services, and external systems 

```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}
```

- Statefile: We will be using S3 bucket to store Terraform state file. Ensure the bucket is already created to make use of
```
terraform {
  backend "s3" {
    bucket = "eks-demo-prod-bucket"
    key    = "terraform/dev-blue.tfstate"
    region = "us-east-1"
  }
}
```

Run ```terraform init``` to initialize the directory and ensure all the necessary plugins and dependencies are downloaded


The architectural diagram needed to setup this infrastructure can be found below



We will be starting our infrastructure provisioning with VPC, which is where all the resources will be located.

## VPC
Key Notes:
- High availabiliy: To ensure we have high availability we are working with 2 AZs.
- Private subnets: To deploy our worker nodes and database.
- NatGateway: Enable NatGateway and using a single NatGateway to minimise cost

```
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  # VPC Basic Details
  name            = var.vpc_name
  cidr            = var.cidr
  azs             = ["${var.region}a", "${var.region}b"]
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  # Database Subnet Setup  
  create_database_subnet_group = var.create_database_subnet_group
  database_subnets             = var.database_subnets
  database_subnet_group_name   = var.database_subnet_group_name

  # VPC DNS Parameters
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  # VPC DNS Parameters
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = var.tags
}
```

```
##############
# VPC Variables
###############
vpc_name                     = "EKS-VPC"
cidr                         = "10.0.0.0/16"
region                       = "us-east-1"
public_subnets               = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets              = ["10.0.3.0/24", "10.0.4.0/24"]
create_database_subnet_group = true
database_subnets             = ["10.0.5.0/24", "10.0.6.0/24"]
database_subnet_group_name   = "db-subnet"
enable_nat_gateway           = true
single_nat_gateway           = true
enable_dns_hostnames         = true
enable_dns_support           = true
tags = {
  Terraform   = "true"
  Environment = "dev"
}
```

Run ```terraform apply``` to provision VPC

<img width="1414" alt="image" src="https://github.com/Taiwolawal/Infrastructure-setup/assets/50557587/cb57dcb3-ac1b-4eb1-a0a6-e1826a3ed5d0">

<img width="1421" alt="image" src="https://github.com/Taiwolawal/Infrastructure-setup/assets/50557587/90f90e88-3378-4a54-9dbf-172b90ee156c">

<img width="1396" alt="image" src="https://github.com/Taiwolawal/Infrastructure-setup/assets/50557587/0e235c5f-7345-4ff6-bcd7-a3c10aca7a8a">


## Database
Key Notes:
- Username and password credentials: To avoid pushing sensitive information like database username and password to gitrepo, we can make use AWS Secret Manager to store them
- Security group: We need to setup a firewall for the database

Setting up AWS Secret Manager to store the credentials
- Select the type of secret you want to store and enter the values

<img width="822" alt="image" src="https://github.com/Taiwolawal/Infrastructure-setup/assets/50557587/a20031ad-a285-4e08-8404-cd6716249390">

- Specify the name you want to give the secret (db-creds-v2)

<img width="848" alt="image" src="https://github.com/Taiwolawal/Infrastructure-setup/assets/50557587/558281fe-e983-4c2e-9018-ba7ac9114dfd">

- Save the secret

<img width="1381" alt="image" src="https://github.com/Taiwolawal/Infrastructure-setup/assets/50557587/17cdf53b-923f-4c07-88a3-c18bc4af73ea">

We will reference the secret we created which contains the username and password for the database setup

Setting up Security group for the database

```
module "sg-rds" {
  source                   = "terraform-aws-modules/security-group/aws"
  version                  = "4.9.0"
  name                     = var.sg-name
  vpc_id                   = module.vpc.vpc_id
  create                   = var.create
  ingress_cidr_blocks      = var.ingress_cidr_blocks
  ingress_rules            = var.ingress_rules
  ingress_with_cidr_blocks = var.ingress_with_cidr_blocks
  egress_with_cidr_blocks  = var.egress_with_cidr_blocks
  egress_cidr_blocks       = var.egress_cidr_blocks
  egress_rules             = var.egress_rules
}
```

```
################
# Security-Group-RDS variables
################
sg-name             = "mysql-rds-sg"
create              = true
ingress_cidr_blocks = []
egress_cidr_blocks  = ["10.0.0.0/16"]
ingress_rules       = [/*"http-80-tcp",*/]
egress_rules        = [/*"http-80-tcp",*/]
ingress_with_cidr_blocks = [
  {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    description = "open port range 3306/tcp ingress rule"
    cidr_blocks = "10.0.0.0/16"
  }
]
egress_with_cidr_blocks = []
```

We will setup our database using the secret we created using AWS Secret Manager containing the database username and password and also make use of the security group we created for the database

```
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
```
```
################
# Database variables
################
identifier           = "database1"
create_db_instance   = true
engine               = "mysql"
engine_version       = "8.0.33"
instance_class       = "db.t2.medium"
allocated_storage    = 5
db_name              = "demodb"
port                 = "3306"
family               = "mysql8.0"
major_engine_version = "8.0"
deletion_protection  = false
```



