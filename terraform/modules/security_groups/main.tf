# ── Security Group: ALB ───────────────────────────────────────────────────────
# Acepta tráfico HTTP desde Internet

resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-sg-alb"
  description = "Security Group para el Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP desde Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Todo el trafico saliente"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-sg-alb"
  })
}

# ── Security Group: ECS (WordPress) ──────────────────────────────────────────
# Solo acepta tráfico desde el ALB

resource "aws_security_group" "ecs" {
  name        = "${var.name_prefix}-sg-ecs"
  description = "Security Group para las tasks ECS de WordPress"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Trafico desde el ALB"
    from_port       = var.wordpress_port
    to_port         = var.wordpress_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Todo el trafico saliente (necesario para pull de imagen y conexion a RDS/EFS)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-sg-ecs"
  })
}

# ── Security Group: RDS ───────────────────────────────────────────────────────
# Solo acepta tráfico MySQL desde las tasks ECS

resource "aws_security_group" "rds" {
  name        = "${var.name_prefix}-sg-rds"
  description = "Security Group para RDS MySQL"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL solo desde las tasks ECS"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-sg-rds"
  })
}

# ── Security Group: EFS ───────────────────────────────────────────────────────
# Solo acepta tráfico NFS desde las tasks ECS

resource "aws_security_group" "efs" {
  name        = "${var.name_prefix}-sg-efs"
  description = "Security Group para EFS (wp-content)"
  vpc_id      = var.vpc_id

  ingress {
    description     = "NFS solo desde las tasks ECS"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-sg-efs"
  })
}
