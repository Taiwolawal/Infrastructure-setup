terraform {
  backend "s3" {
    bucket = "s3-eks-backend"
    key    = "terraform/dev-blue.tfstate"
    region = "eu-west-2"
  }
}

# s3-eks-backend
#  key    = "terraform/dev-blue.tfstate"
