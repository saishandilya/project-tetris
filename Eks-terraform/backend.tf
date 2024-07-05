/*
Before using the terraform backend always create an s3 bucket and use it name here
*/

terraform {
  backend "s3" {
    bucket = "devops-terraform-backend-files" # Replace with your actual S3 bucket name
    key    = "tetris/eks/terraform.tfstate"
    region = "us-east-1"
  }
}
