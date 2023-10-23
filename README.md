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
- Security group: We need to setup a firewall for the database.

Setting up AWS Secret manager to store the credentials

https://www.notion.so/eks-task-2b5cad2fedde40648e5a9f2a5db5fcc5?pvs=4#627d3878366e4aeab6b155c10a2763f8
