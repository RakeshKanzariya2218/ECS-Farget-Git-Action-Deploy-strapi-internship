resource "aws_lb" "strapi_alb" {
  name               = "${var.project_name}-strapi-lb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.strapi_sg.id]
  subnets            = data.aws_subnets.default.ids
  tags = { 
    Name = "${var.project_name}-strapi-lb"
   }
}

resource "aws_lb_target_group" "strapi_tg" {
  name     = "${var.project_name}-strapi-tg"
  port     = 1337
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.vpc.id
  target_type = "ip"               # Because Fargate doesn’t attach tasks to EC2 instances, it only attaches ENIs (elastic network interfaces) , so the target group must target IP addresses.
  health_check {
  path                = "/admin"
  matcher             = "200"
  interval            = 5
  timeout             = 2
  healthy_threshold   = 2
  unhealthy_threshold = 2
}

}

resource "aws_lb_listener" "strapi_listener" {
  load_balancer_arn = aws_lb.strapi_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.strapi_tg.arn
  }
}