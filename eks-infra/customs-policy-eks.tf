#############ECR Access for Worker Node################
resource "aws_iam_policy" "ecr_access_for_worker_node" {
  name        = "ecr-access-policy"
  description = "ECR Access Policy"
  policy      = file("policies/FullECRAccessPolicy.json")
}