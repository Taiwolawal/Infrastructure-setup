#############Cluster Autoscaler Policy For EKS################
resource "aws_iam_policy" "ecr_access_for_worker_node" {
  name        = "ecr-access-policy"
  description = "ECR Access Policy"
  policy      = file("policies/FullECRAccess.json")
}