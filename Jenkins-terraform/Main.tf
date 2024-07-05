/*
provider "aws" {
    region = "us-east-1"
}
*/

module "ec2_instance" {
    source = "./modules/ec2_instance"
    ami_value = var.ami
    instance_type_value = var.instancetype
    key_name_value = var.keyname
    # subnet_id_value = var.subnetid
    root_volume_size_value = var.rootvolumesize
    # vpc_id_value = var.vpcid
}