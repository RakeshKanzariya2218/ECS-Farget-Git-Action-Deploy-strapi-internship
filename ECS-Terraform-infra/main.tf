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

  execution_role_arn = "arn:aws:iam::145065858967:role/adarshecsrole"

  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-strapi"
      image     = "${var.ecr_repository_url}:${var.image_tag}"
      essential = true
      portMappings = [{
        containerPort = 1337
        hostPort      = 1337
      }]
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