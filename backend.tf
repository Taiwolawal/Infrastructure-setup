terraform {
  backend "s3" {
    bucket = "eks-demo-prod-bucket"
    key    = "terraform/dev-blue.tfstate"
    region = "us-east-1"
  }
}
