output "eks-endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "eks-cluster-id" {
  value = aws_eks_cluster.eks.cluster_id
}