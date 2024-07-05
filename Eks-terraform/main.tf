/*
provider "aws" {
    region = "us-east-1"
}
*/

module "eks" {
    source = "./modules/eks"
    eks_cluster_name_value = var.eksclustername
    security_group_value = var.vpcsgid
    subnet_ids_value = [var.publicsubnetid1, var.publicsubnetid2]
    key_name_value = var.keyname
}  