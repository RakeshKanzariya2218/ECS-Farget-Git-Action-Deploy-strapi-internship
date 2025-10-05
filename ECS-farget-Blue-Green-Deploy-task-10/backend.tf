terraform {

  backend "s3" {
    bucket = "rakesh.s3bucketpearlthoughts"
    key    = "rakesh-task-10-blue-green.tfstate"
    region = "ap-south-1"
    encrypt      = true  
  }
}