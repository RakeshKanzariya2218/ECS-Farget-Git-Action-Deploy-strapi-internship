
resource "aws_db_subnet_group" "group" {
  name = "${var.project_name}-subnet-group"
  subnet_ids = data.aws_subnets.default.ids 
  tags ={
    Name = "${var.project_name}-subnet-group"
  }
}


# RDS Security Group
resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-rds-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [ aws_security_group.task-sg.id ]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}


resource "aws_db_parameter_group" "postgres_dev" {
  name        = "${var.project_name}-postgres-pg"
  family      = "postgres16"
  description = "Custom PG parameter group for dev without SSL"

  parameter {
    name  = "rds.force_ssl"
    value = "0"
  }
}



resource "aws_db_instance" "rds-1" {
  allocated_storage = 20                              
  identifier = "${var.project_name}-postgres"                           
  db_name = "dev"                                     
  engine = "postgres"                                    
  engine_version = "16.3"                              
  instance_class = "db.t3.micro"                                        
  username = var.db_username     
  password = var.db_password              
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]      
  db_subnet_group_name = aws_db_subnet_group.group.id
  parameter_group_name = aws_db_parameter_group.postgres_dev.name        
  backup_retention_period = 7                        
  backup_window = "02:00-03:00"                       
  maintenance_window = "sun:04:00-sun:05:00"                            
  skip_final_snapshot = true                          
  depends_on = [ aws_db_subnet_group.group ]   

  tags = {
    Name = "${var.project_name}-postgres"
  }      
}