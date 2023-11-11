# module "sg-rds" {
#   source                   = "terraform-aws-modules/security-group/aws"
#   version                  = "4.9.0"
#   name                     = var.sg-name
#   vpc_id                   = var.vpc_id
#   create                   = var.create
#   ingress_cidr_blocks      = var.ingress_cidr_blocks
#   ingress_rules            = var.ingress_rules
#   ingress_with_cidr_blocks = var.ingress_with_cidr_blocks
#   egress_with_cidr_blocks  = var.egress_with_cidr_blocks
#   egress_cidr_blocks       = var.egress_cidr_blocks
#   egress_rules             = var.egress_rules
# }