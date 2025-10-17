
############ iam role and policy ##############

data "aws_iam_role" "ecs_task_execution_role" {
  name = "adarshecsrole"
}




######### security group ##############



resource "aws_security_group" "strapi_sg" {
  name   = "${var.project_name}-strapi-sg"
  vpc_id = data.aws_vpc.vpc.id
  tags = { 
    Name = "${var.project_name}-strapi-sg"
   }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port       = 1337
    to_port         = 1337
    protocol        = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
   }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}