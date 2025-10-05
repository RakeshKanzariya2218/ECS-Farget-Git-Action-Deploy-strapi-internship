resource "aws_codedeploy_app" "strapi" {
  name             = "${var.project_name}-codedeploy-app"
  compute_platform = "ECS"
}




resource "aws_codedeploy_deployment_group" "strapi" {
  app_name              = aws_codedeploy_app.strapi.name
  deployment_group_name = "${var.project_name}-deployment-group"
  service_role_arn      = data.aws_iam_role.code_deploy_role.arn 

  deployment_config_name = "CodeDeployDefault.ECSCanary10Percent5Minutes"

  ecs_service {
    cluster_name = aws_ecs_cluster.strapi_cluster.name
    service_name = aws_ecs_service.strapi_service.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.https_listener.arn]
      }

      # Optional: use test_traffic_route for pre-traffic validation (if needed)
      test_traffic_route {
        listener_arns = [aws_lb_listener.http_listener.arn]
      }

      target_group {
        name = aws_lb_target_group.strapi_tg_blue.name
      }

      target_group {
        name = aws_lb_target_group.strapi_tg_green.name
      }
    }
  }

   blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 0
    }
  }
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }
}




