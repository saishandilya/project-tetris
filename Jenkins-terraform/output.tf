output "jenkins-instance-ip" {
  value = module.ec2_instance.jenkins-instance-public-ip
}

output "jenkins-instance-id" {
  value = module.ec2_instance.jenkins-instance-id
}

output "jenkins-instance-sg" {
  value = module.ec2_instance.jenkins-instance-sg-id
}