resource "aws_lb" "strapi_alb" {
  name               = "${var.project_name}-lb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb-sg.id]
  subnets            = data.aws_subnets.default.ids
  tags = { 
    Name = "${var.project_name}-strapi-lb"
   }
}


# ---------  Target Group ------------# 

resource "aws_lb_target_group" "strapi_tg_blue" {
  name        = "${var.project_name}-tg-blue"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.vpc.id
  target_type = "ip"
  health_check {
    path                = "/admin"
    matcher             = "200"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "strapi_tg_green" {
  name        = "${var.project_name}-tg-green"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.vpc.id
  target_type = "ip"
  health_check {
    path                = "/admin"
    matcher             = "200"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}



# ------------ Load balancer Listner  -----------# 

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.strapi_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.strapi_tg_blue.arn
  }
}


resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.strapi_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn 

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.strapi_tg_blue.arn
  }
}
