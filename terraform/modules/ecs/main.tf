# ── CloudWatch Log Group ──────────────────────────────────────────────────────

resource "aws_cloudwatch_log_group" "wordpress" {
  name              = "/ecs/${var.name_prefix}/wordpress"
  retention_in_days = 7

  tags = var.tags
}

# ── ECS Cluster ───────────────────────────────────────────────────────────────

resource "aws_ecs_cluster" "this" {
  name = "${var.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-cluster"
  })
}

# ── Task Definition ───────────────────────────────────────────────────────────
# Usa LabRole preexistente — no crea IAM roles

data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

resource "aws_ecs_task_definition" "wordpress" {
  family                   = "${var.name_prefix}-wordpress"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.task_cpu
  memory                   = var.task_memory

  # LabRole se usa tanto para ejecutar la task como para que el agente de ECS
  # pueda hacer pull de la imagen y escribir logs en CloudWatch
  execution_role_arn = data.aws_iam_role.lab_role.arn
  task_role_arn      = data.aws_iam_role.lab_role.arn

  # Volumen EFS para wp-content
  volume {
    name = "wp-content"

    efs_volume_configuration {
      file_system_id          = var.efs_file_system_id
      root_directory          = "/"
      transit_encryption      = "DISABLED"
      authorization_config {
        iam = "DISABLED"
      }
    }
  }

  container_definitions = jsonencode([
    {
      name      = "wordpress"
      image     = var.wordpress_image
      essential = true

      portMappings = [
        {
          containerPort = var.wordpress_port
          hostPort      = var.wordpress_port
          protocol      = "tcp"
        }
      ]

      environment = [
        { name = "WORDPRESS_DB_HOST",     value = var.db_host },
        { name = "WORDPRESS_DB_USER",     value = var.db_username },
        { name = "WORDPRESS_DB_PASSWORD", value = var.db_password },
        { name = "WORDPRESS_DB_NAME",     value = var.db_name },
        # WordPress necesita saber la URL real del ALB para generar enlaces correctos
        { name = "WORDPRESS_CONFIG_EXTRA", value = "" }
      ]

      mountPoints = [
        {
          sourceVolume  = "wp-content"
          containerPath = "/var/www/html/wp-content"
          readOnly      = false
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.wordpress.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "wordpress"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:${var.wordpress_port}/wp-login.php || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-task-wordpress"
  })
}

# ── ECS Service ───────────────────────────────────────────────────────────────

resource "aws_ecs_service" "wordpress" {
  name            = "${var.name_prefix}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.wordpress.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  # Permite actualizar la imagen sin downtime
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "wordpress"
    container_port   = var.wordpress_port
  }

  # Ignora cambios en desired_count para no revertir escalados manuales
  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-service"
  })
}
