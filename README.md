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




The architectural diagram needed to setup this infrastructure can be found below

<img width="792" alt="image" src="https://github.com/Taiwolawal/Infrastructure-setup/assets/50557587/feaa2a8c-b9cb-4dc7-9432-03673e13bcc3">


We will be starting our infrastructure provisioning with VPC, which is where all the resources will be located and the setups will be created using modules. Modules allow for code reusability

![image](https://github.com/Taiwolawal/Infrastructure-setup/assets/50557587/8f249925-a093-49b1-95ba-bec9b0080871)


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


## ECR
Key Notes:
Private Repository: Specify the repository to be private

```
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
```
```
################
# ECR variables
################
repository_name         = "my-ecr"
repository_type         = "private"
create_lifecycle_policy = false
```

## EKS
Setting up EKS, ensure to provide provider for kubernetes. The configuration essentially sets up the kubernetes provider with the necessary information to authenticate and interact with the EKS cluster. 

```
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}
```

KeyNotes:
- Worker Nodes: The worker nodes will be placed inside the private subnet which helps to enhance security by reducing its exposure to potential threats and reducing surface attack.
- Managed Node Group: We will make use of manage node group options since AWS help with Node upgrades, eliminating the need for manual update in the node group and other advantages.
- Instance Type: We will make use of different instances for different workloads to help minimize cost as much as possible e.g. using a mix of spot and on-demand instances. 
- Adding users: To allow users to connect to the cluster, we specify manage_aws_auth_configmap to be true.
- ECR Access: There is need to give the worker nodes access to pull and push to the ECR

Create policy giving access to perform certain action against ECR

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ecr:DescribeImageScanFindings",
                "ecr:StartImageScan",
                "ecr:GetDownloadUrlForLayer",
                "ecr:UploadLayerPart",
                "ecr:BatchDeleteImage",
                "ecr:ListImages",
                "ecr:PutImage",
                "ecr:BatchGetImage",
                "ecr:CompleteLayerUpload",
                "ecr:DescribeImages",
                "ecr:InitiateLayerUpload",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetRepositoryPolicy",
                "ecr:GetLifecyclePolicy"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "ecr:DescribeRegistry",
                "ecr:DescribePullThroughCacheRules",
                "ecr:GetAuthorizationToken"
            ],
            "Resource": "*"
        }
    ]
}

```

Create a custom policy for the eks

```
#############ECR Access for Worker Node################
resource "aws_iam_policy" "ecr_access_for_worker_node" {
  name        = "ecr-access-policy"
  description = "ECR Access Policy"
  policy      = file("policies/FullECRAccessPolicy.json")
}
```

Attach the policy as a role to eks

```
module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "18.29.0"
  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_addons                  = var.cluster_addons
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.private_subnets
  enable_irsa                     = var.enable_irsa
  eks_managed_node_groups         = var.eks_managed_node_groups
  manage_aws_auth_configmap       = var.manage_aws_auth_configmap
  aws_auth_roles = var.aws_auth_roles
  iam_role_additional_policies = var.iam_role_additional_policies
  eks_managed_node_group_defaults = var.eks_managed_node_group_defaults

  tags = var.tags
}

```
The values for the role are highlighted in the screenshot below

![image](https://github.com/Taiwolawal/Infrastructure-setup/assets/50557587/d8fdec05-76af-4ef5-8b5c-f5dfe0302aac)

If a user wants to connect to the cluster:
- Create a policy for eks access
- Create IAM role to access the cluster
- Assume the IAM role
- Attach the role to aws_auth_roles

![image](https://github.com/Taiwolawal/Infrastructure-setup/assets/50557587/b18256d5-7d7b-4ab0-a28a-9dadc9a8720d)


```
## Policy to allow access to EKS
module "eks_admin_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.3.1"

  name          = "allow-eks-access-admin"
  create_policy = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

## IAM Role that will be used to access the cluster
module "eks_admins_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.3.1"

  role_name         = "eks-admin"
  create_role       = true
  role_requires_mfa = false

  custom_role_policy_arns = [module.eks_admin_iam_policy.arn]

  trusted_role_arns = [
    "arn:aws:iam::${module.vpc.vpc_owner_id}:root"
  ]
}

## IAM policy to assume the IAM role
module "allow_assume_eks_admins_iam_policy" {
  source        = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version       = "5.3.1"
  name          = "allow-assume-eks-admin-iam-role"
  create_policy = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
        ]
        Effect   = "Allow"
        Resource = module.eks_admins_iam_role.iam_role_arn
      },
    ]
  })
}

```

```
################
# EKS variables
################
cluster_name                    = "dev-eks"
cluster_version                 = "1.28"
cluster_endpoint_private_access = true
cluster_endpoint_public_access  = true
cluster_addons = {
  coredns = {
    most_recent = true
  }
  kube-proxy = {
    most_recent = true
  }
  vpc-cni = {
    most_recent = true
  }
}

manage_aws_auth_configmap = true
enable_irsa               = true
eks_managed_node_groups = {
  general = {
    desired_size = 1
    min_size     = 1
    max_size     = 10

    instance_types = ["t3.medium"]
    capacity_type  = "ON_DEMAND"
  }

  spot = {
    desired_size = 1
    min_size     = 1
    max_size     = 10

    instance_types = ["t3.medium"]
    capacity_type  = "SPOT"
  }
}
```

Run ```terraform init``` to download the necessary modules and run ```terraform apply```

<img width="1187" alt="image" src="https://github.com/Taiwolawal/Infrastructure-setup/assets/50557587/2e2f958f-9777-4bb2-ac3e-92f7d85a12b0">

<img width="1399" alt="image" src="https://github.com/Taiwolawal/Infrastructure-setup/assets/50557587/76eeff91-53bf-426f-8315-e9a6e9adc91c">

<img width="1400" alt="image" src="https://github.com/Taiwolawal/Infrastructure-setup/assets/50557587/8201da8f-b059-4f32-bb68-178e8a6dc97a">

<img width="1410" alt="image" src="https://github.com/Taiwolawal/Infrastructure-setup/assets/50557587/33237560-24a7-4ac1-b3de-ab7e3ef06e79">

<img width="1396" alt="image" src="https://github.com/Taiwolawal/Infrastructure-setup/assets/50557587/2d60de74-7fbf-4632-8575-fd7fb29e3d0f">

<img width="1383" alt="image" src="https://github.com/Taiwolawal/Infrastructure-setup/assets/50557587/e6de8fdc-9780-4dd0-83af-f9b108998b71">

<img width="1418" alt="image" src="https://github.com/Taiwolawal/Infrastructure-setup/assets/50557587/5f88ddf7-8709-4517-92e8-9c0aa44b4807">

<img width="1398" alt="image" src="https://github.com/Taiwolawal/Infrastructure-setup/assets/50557587/c8496c15-45f4-41aa-a332-5fb3917f8e94">

<img width="1152" alt="image" src="https://github.com/Taiwolawal/Infrastructure-setup/assets/50557587/d059659c-6c02-4f4d-b09d-6708d1deaefe">

<img width="1379" alt="image" src="https://github.com/Taiwolawal/Infrastructure-setup/assets/50557587/7f3f10db-676d-4419-a3f8-fe207596d43d">

<img width="1389" alt="image" src="https://github.com/Taiwolawal/Infrastructure-setup/assets/50557587/ffeb13c0-41ad-4175-b999-be25bf2df69b">

<img width="1373" alt="image" src="https://github.com/Taiwolawal/Infrastructure-setup/assets/50557587/4a49d694-ce9d-4db1-83e1-8607beed6cf3">

<img width="1430" alt="image" src="https://github.com/Taiwolawal/Infrastructure-setup/assets/50557587/33d8bd6c-9abe-4bff-855a-14df88dcb696">



## Working with helm Chart
We will deploy argocd to the cluster

You can use terraform also to deploy applications to your cluster. Ensure you add helm provider and run ```terraform init``` to download the necessary plugin needed to use helm on the cluster.

```
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
      command     = "aws"
    }
  }
}
```

Connect to the cluster ```aws eks update-kubeconfig --name dev-eks --region us-east-1```

Add argo helm chart ```helm repo add argo https://argoproj.github.io/argo-helm```

```helm search repo argocd ``` 

<img width="956" alt="image" src="https://github.com/Taiwolawal/Infrastructure-setup/assets/50557587/657182c5-f6fb-4e69-b440-aec0ef369d65">

To see the values of argocd helm you will be working with, you can tweak the values for your use case.

```helm show values argo/argo-cd --version 3.35.4 > argocd.yaml``` 


To deploy argocd to the cluster run the code below. To use your own values for argocd, download argocd values, edit the values and specify the path to the file.

```
resource "helm_release" "argocd" {
  name = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "3.35.4"

  values = [file("helm-value/argocd.yaml")]
}
```

Run ```terraform apply``` to deploy argocd

![image](https://github.com/Taiwolawal/Infrastructure-setup/assets/50557587/72679d1d-c519-49dc-bf0d-109e00381ea5)

Get the password to log into argocd, ignore  % when copying 

![image](https://github.com/Taiwolawal/Infrastructure-setup/assets/50557587/a0e9d250-c19d-4736-bd25-77bc07f373aa)

<img width="1424" alt="image" src="https://github.com/Taiwolawal/Infrastructure-setup/assets/50557587/f25046ec-5e95-4b12-9a68-f1e96c261561">

<img width="1429" alt="image" src="https://github.com/Taiwolawal/Infrastructure-setup/assets/50557587/80d25ed7-15b2-4175-aea6-5ea3368cc37f">


# ArgoCD Usage

We will be using argocd to deploy applications on the cluster and focus on the points below 

- Helm & Kustomize: Application deployment can be done using helm chart and also kustomise to deploy to different environments you want to.
- Private Repo: How to handle private repo.
- Apps of App: Deploying a lot of applications at the same can be very tasking, using the apps of pattern it allows you to just deploy from one file.
- Secret: How to handle sensitive information 
- Image Updater: How to handle updating images on manifest file the gitops proper way.















