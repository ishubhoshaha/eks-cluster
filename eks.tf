resource "aws_eks_cluster" "eks" {
  name = local.eks_cluster_name
  vpc_config {
    subnet_ids              = [aws_subnet.private-subnet-1a.id, aws_subnet.private-subnet-1b.id, aws_subnet.private-subnet-1c.id]
    security_group_ids      = [aws_security_group.eks-cluster-sg.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }
  enabled_cluster_log_types = ["api", "audit"]
  role_arn                  = aws_iam_role.eks-cluster-role.arn
  version                   = local.k8_version
  tags                      = merge(map("Name", join("-", [local.env, local.project, "eks-cluster"])), map("ResourceType", "EKS"), local.common_tags)
}

