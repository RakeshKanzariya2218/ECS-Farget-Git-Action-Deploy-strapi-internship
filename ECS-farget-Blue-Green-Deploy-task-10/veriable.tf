variable "region" {
  default = "us-east-1"
}

variable "vpc_id" {
  default = "vpc-08d5eddd5bf3a6907"
}



variable "project_name" {
  default = "rakesh-blue-green"
}

variable "image_tag" {
type = string
default = ""
}


variable "ecr_repository_url" {
type = string
default = "132866222051.dkr.ecr.us-east-1.amazonaws.com/rakesh-blue-green-ecs"
}


variable "db_password" {
  type      = string
  sensitive = true
}


variable "db_username" {
  type      = string
  sensitive = true
}


variable "acm_certificate_arn" {
  description = "ARN of ACM certificate for HTTPS listener"
  type        = string
  sensitive = true
}
