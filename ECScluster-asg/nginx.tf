# ============================================================
# Nginx Backend ECS Task Definition
# ============================================================

resource "aws_ecs_task_definition" "nginx" {
  family                   = "nginx"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]

  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "${aws_ecr_repository.nginx_backend.repository_url}:${var.image_tag}"
      essential = true
      memory    = 256

      portMappings = [
        {
          containerPort = 80
          hostPort = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}


# ============================================================
# Nginx Backend ECS Service
# ============================================================

resource "aws_ecs_service" "nginx" {
  name            = "nginx-service"
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.nginx.arn

  desired_count = 1
  launch_type   = "EC2"

  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100

  network_configuration {
    subnets = [
      data.terraform_remote_state.vpc.outputs.public_subnet_id
    ]

    security_groups = [
      aws_security_group.ecs_instance.id
    ]


  }

  service_registries {
    registry_arn   = aws_service_discovery_service.nginx.arn
    container_name = "nginx"
  }
}


# ============================================================
# Nginx Proxy ECS Task Definition
# ============================================================

resource "aws_ecs_task_definition" "nginx_proxy" {
  family                   = "nginx-proxy"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]

  container_definitions = jsonencode([
    {
      name      = "nginx-proxy"
      image     = "${aws_ecr_repository.nginx_proxy.repository_url}:${var.image_tag}"
      essential = true
      memory    = 256

      portMappings = [
        {
          containerPort = 80
          hostPort = 8080
          protocol      = "tcp"
        }
      ]
    }
  ])
}


# ============================================================
# Nginx Proxy ECS Service
# ============================================================

resource "aws_ecs_service" "nginx_proxy" {
  name            = "nginx-proxy-service"
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.nginx_proxy.arn

  desired_count = 1
  launch_type   = "EC2"

  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100

  network_configuration {
    subnets = [
      data.terraform_remote_state.vpc.outputs.public_subnet_id
    ]

    security_groups = [
      aws_security_group.ecs_instance.id
    ]


  }
}