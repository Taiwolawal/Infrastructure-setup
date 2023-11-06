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

