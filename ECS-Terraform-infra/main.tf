##### cluster #####

resource "aws_ecs_cluster" "strapi_cluster" {
  name = "${var.project_name}-strapi-cluster"
}

##### task definition = ~deployment.yaml ##########

resource "aws_ecs_task_definition" "strapi_task" {
  family                   = "${var.project_name}-strapi-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"

  execution_role_arn = "arn:aws:iam::132866222051:role/adarshecsrole"

  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-strapi"
      image     = "${var.ecr_repository_url}:${var.image_tag}"
      essential = true

      portMappings = [
        {
          containerPort = 1337
          hostPort      = 1337
        }
      ]
      

      environment = [
        { name = "HOST", value = "0.0.0.0" },
        { name = "PORT", value = "1337" },
        {name  = "JWT_SECRET", value = "your-randomly-generated-secret"},
        { name = "DATABASE_CLIENT", value = "sqlite" },
        { name = "APP_KEYS", value = "randomkey123" },
        { name = "API_TOKEN_SALT", value = "randomsalt123" },
        { name = "ADMIN_JWT_SECRET", value = "adminsecret123" }
      ]
      
      
      logConfiguration = {
      logDriver = "awslogs"
      options = {
      awslogs-group         = "/ecs/${var.project_name}-strapi"
      awslogs-region        = var.region
      awslogs-stream-prefix = "ecs"
  }
}


      mountPoints = [
  {
    sourceVolume  = "strapi-data"
    containerPath = "/app/public/uploads"
    readOnly      = false
  }
]
    }
  ])

  volume {
    name = "strapi-data"

    efs_volume_configuration {
      file_system_id = aws_efs_file_system.strapi_efs.id
      root_directory      = "/"
      transit_encryption  = "ENABLED"
    }
  }
}


resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/${var.project_name}-strapi"
  retention_in_days = 7
}


######### ecs service ##################


resource "aws_ecs_service" "strapi_service" {
  name            = "${var.project_name}-strapi-service"
  cluster         = aws_ecs_cluster.strapi_cluster.id
  task_definition = aws_ecs_task_definition.strapi_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = data.aws_subnets.default.ids
    security_groups = [aws_security_group.strapi_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.strapi_tg.arn
    container_name   = "${var.project_name}-strapi"
    container_port   = 1337
  }

  depends_on = [aws_lb_listener.strapi_listener ]
}