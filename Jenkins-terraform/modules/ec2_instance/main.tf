provider "aws" {
    region = "us-east-1"
}

resource "aws_iam_role" "ec2_instance_role" {
  name = "jenkins_instance_role"

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

# Attach the AmazonS3FullAccess to the role
resource "aws_iam_role_policy_attachment" "ec2_instance_policy" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# IAM Instance Profile for EC2 Jenkins Instance
resource "aws_iam_instance_profile" "ec2_jenkins_instance_profile" {
  name = "ec2_jenkins_instance_profile"
  role = aws_iam_role.ec2_instance_role.name
}

resource "aws_security_group" "jenkins-instance-sg" {
  name   = "jenkins-instance-sg"
  description = "Allow 22, 80, 443, 8080, 9000, 3000"
  # vpc_id = var.vpc_id_value

  # Define ingress rules for the specified ports
  ingress = [
    for port in [22, 80, 443, 8080, 9000, 3000] : {
      description      = "Allow TCP traffic on port ${port}"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  # Define egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-instance-sg"
  }
}

resource "aws_instance" "jenkins-instance" {
  ami                    = var.ami_value
  instance_type          = var.instance_type_value
  key_name               = var.key_name_value
  vpc_security_group_ids = [aws_security_group.jenkins-instance-sg.id]
  # subnet_id              = var.subnet_id_value
  iam_instance_profile   = aws_iam_instance_profile.ec2_jenkins_instance_profile.name
  user_data              = templatefile("./install_jenkins.sh", {})
  root_block_device {
    volume_size = var.root_volume_size_value
  }
  tags = {
    Name = "jenkins-instance"
  }
}