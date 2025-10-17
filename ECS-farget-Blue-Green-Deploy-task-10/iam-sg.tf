
############ iam role and policy ##############

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

 data "aws_iam_role" "code_deploy_role" {
  name = "ecs-codedeploy"
 }




######### security group ##############



resource "aws_security_group" "task-sg" {
  name   = "${var.project_name}-task-sg"
  vpc_id = data.aws_vpc.vpc.id
  tags = { 
    Name = "${var.project_name}-strapi-sg"
   }

   ingress {
    from_port       = 1337
    to_port         = 1337
    protocol        = "tcp"
    security_groups = [ aws_security_group.lb-sg.id ]
   }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


#------  Load Blancer Security Group ------------# 

resource "aws_security_group" "lb-sg" {
  name   = "${var.project_name}-lb-sg"
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
    from_port       = 443
    to_port         = 443
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

