/*
provider "aws" {
    region = "us-east-1"
}
*/

module "eks" {
    source = "./modules/eks"
    eks_cluster_name_value = var.eksclustername
    security_group_value = var.vpcsgid
}  