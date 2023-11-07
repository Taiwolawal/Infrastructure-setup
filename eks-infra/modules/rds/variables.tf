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
variable "database_subnet_group_name" {
  type = string
}
variable "database_subnets" {
  type    = list(any)
  default = []
}
variable "port" {
  type = string
}
variable "vpc_security_group_ids" {
  type = list(string)
}
variable "username" {
  type = string
}
variable "password" {
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

variable "tags" {
  type    = map(any)
  default = {}
}

