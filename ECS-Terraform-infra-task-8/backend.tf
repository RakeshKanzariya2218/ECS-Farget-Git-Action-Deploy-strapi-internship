terraform {

  backend "s3" {
    bucket = "rakesh.s3bucketpearlthoughts"
    key    = "${var.project_name}-task-8-cloudwatch-terraform.tfstate"
    region = "ap-south-1"
    encrypt      = true  
  }
}