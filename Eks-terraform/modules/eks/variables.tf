variable "eks_cluster_name_value" {
    description = "value for the eks cluster"
}

variable "security_group_value" {
    description = "value for the default vpc sg for jenkins"
}

variable "subnet_ids_value" {
  type = list
}

variable "key_name_value" {
  description = "value of the key pair"
}