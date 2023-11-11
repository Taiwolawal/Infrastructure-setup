
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

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "aws_auth_roles" {
  type = list(any)
}

variable "aws_auth_users" {
  type = list(any)
}
variable "iam_role_additional_policies" {
  # type = list(string)
  type = map(string)
}

variable "enable_irsa" {
  type = bool
}

variable "eks_managed_node_group_defaults" {
  type = any
  # type = map(any)
}

variable "eks_managed_node_groups" {
  type = map(any)
}

variable "manage_aws_auth_configmap" {
  type = bool
}

variable "tags" {
  type    = map(any)
  default = {}
}


