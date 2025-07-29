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
      portMappings = [{ containerPort = 5000, protocol = "tcp" }]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "/ecs/backend-task"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "backend"
        }
      }
      environment = [
        { name = "FLASK_APP", value = "realworld.app" },
        { name = "FLASK_ENV", value = "production" },
        { name = "FLASK_RUN_PORT", value = "5000" },
        { name = "POSTGRES_HOST", value = "postgres" },
        { name = "POSTGRES_DB", value = "projectdb" },
        { name = "POSTGRES_USER", value = "dbadmin" },
        { name = "POSTGRES_PASSWORD", value = "password" },
      ]
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://127.0.0.1:5000/api/health || exit 1"]
        interval    = 30    # seconds between checks
        timeout     = 5     # fail if takes longer than 5s
        retries     = 3     # number of failed attempts before marking unhealthy
        startPeriod = 60    # wait 10s before starting health checks
      }
    }
  ])
}

resource "aws_ecs_service" "frontend" {
  name            = "frontend-service"
  cluster         = var.cluster_id
  desired_count   = 1
  task_definition = aws_ecs_task_definition.frontend.arn

#  depends_on = [
#    aws_lb_listener.https_listener
#  ]

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
  }

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.frontend_sg_id]
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
    security_groups  = [var.backend_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_backend_tg_arn
    container_name   = "backend"
    container_port   = 5000
  }
}