terraform {

  backend "s3" {
    bucket = "rakesh.s3bucketpearlthoughts"
    key    = "rakesh-task-8-cloudwatch-ecs-terraform.tfstate"
    region = "ap-south-1"
    encrypt      = true  
  }
}