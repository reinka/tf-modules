resource "aws_eks_cluster" "this" {
  name = var.name
  role_arn = aws_iam_role.cluster.arn
  version = "1.34"

  access_config {
    authentication_mode = "API"
  }

  compute_config {
    enabled = true
    node_pools = [ "general-purpose" ]
    node_role_arn = aws_iam_role.node.arn
  }

  kubernetes_network_config {
    elastic_load_balancing {
      enabled = true
    }
  }

  storage_config {
    block_storage {
      enabled = true
    }
  }

  bootstrap_self_managed_addons = false

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access = true
    subnet_ids = aws_subnet.private[*].id

    public_access_cidrs = var.public_access_cidrs
  }

  tags = {
    Name = "${var.name}-cluster"
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster,
    aws_iam_role_policy_attachment.cluster_AmazonEKSComputePolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSBlockStoragePolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSLoadBalancingPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSNetworkingPolicy,
  ]
}

data "aws_caller_identity" "current" {}

data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}

resource "aws_eks_access_entry" "admin_user" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = data.aws_iam_session_context.current.issuer_arn
  
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin_user" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = aws_eks_access_entry.admin_user.principal_arn
  
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  
  access_scope {
    type = "cluster"
  }
}