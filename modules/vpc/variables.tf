variable "region" {
  default = "us-east-1"
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

# variable "create_database_subnet_group" {
#   type    = bool
#   default = true
# }

# variable "database_subnets" {
#   type    = list(any)
#   default = []
# }

# variable "database_subnet_group_name" {
#   type = string
# }

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