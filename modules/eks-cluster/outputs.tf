output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_sn_ids" {
  value = aws_subnet.public[*].id
}

output "public_sn_cidr_blocks" {
  value = aws_subnet.public[*].cidr_block
}

output "private_sn_ids" {
  value = aws_subnet.private[*].id
}

output "private_sn_cidr_blocks" {
  value = aws_subnet.private[*].cidr_block
}

output "cluster_iam_role_arn" {
  description = "ARN of the EKS cluster IAM role."
  value = aws_iam_role.cluster.arn
}

output "node_iam_role_arn" {
  description = "ARN of the EKS node group IAM role."
  value = aws_iam_role.node.arn
}

output "public_access_cidrs" {
  description = "Public CIDRs allowed to access the cluster."
  value = aws_eks_cluster.this.vpc_config[0].public_access_cidrs
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster's API server."
  value = aws_eks_cluster.this.endpoint
}

output "cluster_name" {
  description = "The name of the EKS cluster."
  value = aws_eks_cluster.this.name
}