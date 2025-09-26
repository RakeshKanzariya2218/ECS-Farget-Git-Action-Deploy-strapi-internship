variable "region" {
  default = "ap-south-1"
}

variable "vpc_id" {
  default = "vpc-01b35def73b166fdc"
}



variable "project_name" {
  default = "rakesh-gitaction"
}

variable "image_tag" {
type = string
default = ""
}


variable "ecr_repository_url" {
type = string
default = "145065858967.dkr.ecr.ap-south-1.amazonaws.com/rakesh-strapi-gitactoin"
}
