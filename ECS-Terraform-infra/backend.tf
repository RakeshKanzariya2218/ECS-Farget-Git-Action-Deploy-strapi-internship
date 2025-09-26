terraform {

  backend "s3" {
    bucket = "rakesh.s3bucketpearlthoughts"
    key    = "${var.project_name}-terraform.tfstate"
    region = "ap-south-1"
    encrypt      = true  
  }
}