provider "aws" {
  region = var.region
}

resource "aws_ecr_repository" "app" {
  name                 = var.app_name
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = false
  }

  provisioner "local-exec" {
    command = "./create_push_image_to_ecr.sh $REGION $URL $APP_NAME $IMAGE_TAG"

    environment = {
      REGION    = var.region
      APP_NAME  = var.app_name
      URL       = replace(self.repository_url, format("/%s", var.app_name), "")
      IMAGE_TAG = "${var.app_name}:${var.image_tag}"
    }
  }

  tags = var.tags
}

resource "aws_ecs_cluster" "app_cluster" {
  name = var.cluster_name
  tags = var.tags
}

resource "aws_iam_role" "task_execution_iam_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = [
            "ecs-tasks.amazonaws.com"
          ]
        }
      },
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchFullAccess",
    "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess",
  ]
}

resource "aws_ecs_task_definition" "app" {
  family                   = "app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 3072
  execution_role_arn       = aws_iam_role.task_execution_iam_role.arn

  container_definitions = jsonencode(
    [
      {
        image = "${aws_ecr_repository.app.repository_url}"
        name  = var.app_name
        portMappings = [
          {
            appProtocol   = "http"
            containerPort = 80
            hostPort      = 80
            protocol      = "tcp"
          }
        ]

        healthCheck = {
          command = ["CMD-SHELL", "curl --fail http://localhost:80 || exit 1"]
        }
      }
    ]
  )

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
}

resource "aws_ecs_service" "app" {
  name                = var.app_name
  cluster             = aws_ecs_cluster.app_cluster.id
  task_definition     = aws_ecs_task_definition.app.arn
  desired_count       = 1
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"

  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    assign_public_ip = true
    security_groups = [
      aws_security_group.app.id
    ]
    subnets = aws_subnet.public.*.id
  }
}

