output "jenkins-instance-public-ip" {
  value = aws_instance.jenkins-instance.public_ip
}

output "jenkins-instance-id" {
  value = aws_instance.jenkins-instance.id
}

output "jenkins-instance-sg-id" {
  value = aws_security_group.jenkins-instance-sg.id
}