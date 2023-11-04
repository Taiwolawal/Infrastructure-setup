variable "repository_name" {
  type = string
}
variable "repository_type" {
  type = string
}
variable "create_lifecycle_policy" {
  type = bool
}


variable "tags" {
  type    = map(any)
  default = {}
}