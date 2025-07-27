resource "aws_ecs_task_definition" "frontend" {
  family                   = "frontend-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name         = "frontend",
      image        = var.frontend_image_url,
      portMappings = [{ containerPort = 80, protocol = "tcp" }]
    }
  ])
}

resource "aws_ecs_task_definition" "backend" {
  family                   = "backend-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name         = "backend",
      image        = var.backend_image_url,
      portMappings = [{ containerPort = 80, protocol = "tcp" }]
    }
  ])
}

resource "aws_ecs_service" "frontend" {
  name            = "frontend-service"
  cluster         = var.cluster_id
  desired_count   = 1
  task_definition = aws_ecs_task_definition.frontend.arn

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
  }

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_frontend_tg_arn
    container_name   = "frontend"
    container_port   = 80
  }
}

resource "aws_ecs_service" "backend" {
  name            = "backend-service"
  cluster         = var.cluster_id
  desired_count   = 1
  task_definition = aws_ecs_task_definition.backend.arn

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
  }

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_backend_tg_arn
    container_name   = "backend"
    container_port   = 80
  }
}