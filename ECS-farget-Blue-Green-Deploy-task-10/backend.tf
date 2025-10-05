terraform {

  backend "s3" {
    bucket = "rkanzariya.info"
    key    = "rakesh-task-10-blue-green.tfstate"
    region = "us-east-1"
    encrypt      = true  
  }
}