data "aws_vpc" "vpc" {
  id = var.vpc_id
}


data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}

