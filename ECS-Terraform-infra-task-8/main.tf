##### cluster #####

resource "aws_ecs_cluster" "strapi_cluster" {
  name = "${var.project_name}-strapi-cluster"

   setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

##### task definition = ~deployment.yaml ##########

resource "aws_ecs_task_definition" "strapi_task" {
  family                   = "${var.project_name}-strapi-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"

  execution_role_arn = "arn:aws:iam::145065858967:role/adarshecsrole"

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
        { name = "JWT_SECRET", value = "your-randomly-generated-secret" },
        { name = "APP_KEYS", value = "randomkey123" },
        { name = "API_TOKEN_SALT", value = "randomsalt123" },
        { name = "ADMIN_JWT_SECRET", value = "adminsecret123" },

        # --- RDS connection ---
        { name = "DATABASE_CLIENT", value = "postgres" },
        { name = "DATABASE_HOST", value = aws_db_instance.rds-1.address },
        { name = "DATABASE_PORT", value = "5432" },
        { name = "DATABASE_NAME", value = "dev" },
        { name = "DATABASE_USERNAME", value = var.db_username },
        { name = "DATABASE_PASSWORD", value = var.db_password },
        { name = "DATABASE_SSL", value = "0" },
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_strapi.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs/strapi"
        }
      }
    }
  ])
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



#-------   cloudwatch -----------#

resource "aws_cloudwatch_log_group" "ecs_strapi" {
  name              = "${var.project_name}-/ecs/strapi"
  retention_in_days = 7
}

resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts-topic"
}


resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.project_name}-strapi-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  dimensions = {
    ClusterName = aws_ecs_cluster.strapi_cluster.name
    ServiceName = aws_ecs_service.strapi_service.name
  }
  alarm_actions = [aws_sns_topic.alerts.arn]  
}



resource "aws_cloudwatch_dashboard" "ecs_dashboard" {
  dashboard_name = "${var.project_name}-strapi-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        x    = 0
        y    = 0
        width = 12
        height = 6
        properties = {
          metrics = [
            [ "AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.strapi_cluster.name, "ServiceName", aws_ecs_service.strapi_service.name ],
            [ ".", "MemoryUtilization", ".", ".", ".", "." ]
          ]
          view = "timeSeries"
          region = var.region
          title = "CPU & Memory Utilization"
        }
      }
    ]
  })
}
