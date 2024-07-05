provider "aws" {
    region = "us-east-1"
}

resource "aws_iam_role" "eks_role" {
  name = "eks_cluster_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

# Attach the AmazonEKSClusterPolicy to the role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Attach the AmazonEKSServicePolicy to the role
resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

# Attach the AmazonEKSVPCResourceController to the role
resource "aws_iam_role_policy_attachment" "eks_vpc_controller_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

/*
# Fetch default VPC ID
data "aws_vpc" "default_vpc_id" {
  default = true
}

# Fetch public subnets from default VPC
data "aws_subnets" "default_vpc_public_subnet" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc_id.id]
  }
}
*/

# EKS Cluster
resource "aws_eks_cluster" "eks" {
    name = var.eks_cluster_name_value
    role_arn = aws_iam_role.eks_role.arn
    vpc_config {
      subnet_ids      = [var.subnet_ids_value[0],var.subnet_ids_value[1]]
    }
/*
    vpc_config {
        subnet_ids = data.aws_subnets.default_vpc_public_subnet.ids
    }
*/
  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_service_policy,
    aws_iam_role_policy_attachment.eks_vpc_controller_policy
  ]
}

resource "aws_iam_role" "eks_worker_role" {
  name = "eks_worker_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# Attach necessary policies to the worker role
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# IAM Instance Profile for EKS Worker Nodes
resource "aws_iam_instance_profile" "eks_worker_instance_profile" {
  name = "eks_worker_instance_profile"
  role = aws_iam_role.eks_worker_role.name
}

#  EKS Node Group
resource "aws_eks_node_group" "eks_worker_node" {
    cluster_name    = aws_eks_cluster.eks.name
    node_group_name = "dev"
    node_role_arn   = aws_iam_role.eks_worker_role.arn
    subnet_ids      = [var.subnet_ids_value[0],var.subnet_ids_value[1]]
    # subnet_ids      = data.aws_subnets.default_vpc_public_subnet.ids
    capacity_type = "ON_DEMAND"
    disk_size = "20"
    instance_types = ["t2.small"]
    remote_access {
        ec2_ssh_key = var.key_name_value
        source_security_group_ids = [var.security_group_value]
    }
    scaling_config {
        desired_size = 1
        max_size     = 2
        min_size     = 1
    }
    # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
    # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
    depends_on = [
        aws_iam_role_policy_attachment.eks_worker_node_policy,
        aws_iam_role_policy_attachment.eks_cni_policy,
        aws_iam_role_policy_attachment.ssm_managed_instance_core,
        aws_iam_role_policy_attachment.ecr_readonly
    ]
  }