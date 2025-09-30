# Create EFS File System
resource "aws_efs_file_system" "strapi_efs" {
  creation_token   = "${var.project_name}-efs"
  performance_mode = "generalPurpose"
  throughput_mode  = "elastic"

  encrypted = true

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name = "${var.project_name}-efs"
  }
}

# Create Mount Targets in each subnet
resource "aws_efs_mount_target" "strapi_efs_mt" {
  for_each = toset(data.aws_subnets.default.ids) 

  file_system_id  = aws_efs_file_system.strapi_efs.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs_sg.id]
}

# Security group to allow NFS traffic (2049)
resource "aws_security_group" "efs_sg" {
  name        = "${var.project_name}-efs-sg"
  description = "Allow ECS tasks to access EFS"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    security_groups = [aws_security_group.strapi_sg.id] # Allow ECS task SG
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-efs-sg"
  }
}
