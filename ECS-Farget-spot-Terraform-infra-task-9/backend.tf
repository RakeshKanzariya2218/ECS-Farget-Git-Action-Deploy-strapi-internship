terraform {

  backend "s3" {
    bucket = "rakesh.s3bucketpearlthoughts"
    key    = "rakesh-task-9-farget-spot-terraform.tfstate"
    region = "ap-south-1"
    encrypt      = true  
  }
}