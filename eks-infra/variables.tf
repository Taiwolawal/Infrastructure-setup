## VPC VARIABLES
variable "region" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "cidr" {
  type    = string
  default = ""
}

variable "azs" {
  type    = list(any)
  default = []
}

variable "private_subnets" {
  type    = list(any)
  default = []
}

variable "public_subnets" {
  type    = list(any)
  default = []
}

variable "create_database_subnet_group" {
  type    = bool
  default = true
}

variable "database_subnets" {
  type    = list(any)
  default = []
}

variable "database_subnet_group_name" {
  type = string
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateways for Private Subnets Outbound Communication"
  type        = bool
}

variable "single_nat_gateway" {
  type = bool
}

variable "enable_dns_hostnames" {
  type = bool
}

variable "enable_dns_support" {
  type = bool
}

variable "tags" {
  type    = map(any)
  default = {}
}

## EKS VARIABLE

variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "cluster_endpoint_private_access" {
  type = bool
}

variable "cluster_endpoint_public_access" {
  type = bool
}

variable "cluster_addons" {
  type = map(any)
}

# variable "subnet_ids" {
#   type = list(string)
# }

variable "enable_irsa" {
  type = bool
}

# variable "eks_managed_node_group_defaults" {
#   type = map(any)
# }

variable "eks_managed_node_groups" {
  type = map(any)
}

variable "developer_username" {
  type        = string
  description = "Names of developer for aws_auth map and namespaces"
}

variable "admin_username" {
  type        = string
  description = "Name of admin user"
}



variable "manage_aws_auth_configmap" {
  type = bool
}

variable "namespace" {
  type        = string
  description = "Kubernetes namespace to create"
}

## RDS VARIABLE
variable "identifier" {
  type = string
}
variable "create_db_instance" {
  type = bool
}
variable "engine" {
  type = string
}
variable "engine_version" {
  type = string
}
variable "instance_class" {
  type = string
}
variable "allocated_storage" {
  type        = number
  description = "The allocated storage in gigabytes"
}
variable "db_name" {
  type = string
}
variable "port" {
  type = string
}
variable "family" {
  type    = string
  default = "mysql8.0"
}
variable "major_engine_version" {
  type    = string
  default = "8.0"
}
variable "deletion_protection" {
  type    = bool
  default = false
}

## SECURITY-GROUP VARIABLE
variable "sg-name" {
  type    = string
  default = "demosg"
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "create" {
  type    = bool
  default = false
}

variable "ingress_cidr_blocks" {
  type    = any
  default = []
}

variable "ingress_rules" {
  type    = any
  default = []
}

variable "ingress_with_cidr_blocks" {
  type    = any
  default = []
}

variable "egress_with_cidr_blocks" {
  type    = any
  default = []
}

variable "egress_cidr_blocks" {
  type    = any
  default = []
}

variable "egress_rules" {
  type    = any
  default = []
}

## ECR VARIABLE
variable "repository_name" {
  type = string
}

variable "repository_type" {
  type = string
}


variable "create_lifecycle_policy" {
  type = bool
}

# variable "repository_policy" {
#   type = string
# }








