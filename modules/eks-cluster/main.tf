resource "aws_eks_cluster" "this" {
  name = var.name
  role_arn = aws_iam_role.cluster.arn
  version = "1.34"

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access = true
    subnet_ids = aws_subnet.private[*].id

    public_access_cidrs = var.public_access_cidrs
  }

  depends_on = [ aws_iam_role_policy_attachment.cluster ]

  tags = {
    Name = "${var.name}-cluster"
  }
}

resource "aws_eks_node_group" "this" {
  cluster_name = aws_eks_cluster.this.name
  node_group_name = "${var.name}-node-group"
  subnet_ids = aws_subnet.private[*].id
  node_role_arn = aws_iam_role.nodes.arn
  scaling_config {
    min_size = 1
    desired_size = 2
    max_size = 3
  }
  instance_types = ["t3.micro"]

  depends_on = [ aws_eks_cluster.this ]

  tags = {
    Name = "${var.name}-node-group"
  }
}