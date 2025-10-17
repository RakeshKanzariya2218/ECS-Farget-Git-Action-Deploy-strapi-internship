terraform {

  backend "s3" {
    bucket = "rakesh.s3bucketpearlthoughts"
    key    = "rakesh-task-11-codedeploy.tfstate"
    region = "ap-south-1"
    encrypt      = true  
  }
}