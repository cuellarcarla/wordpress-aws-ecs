# ─────────────────────────────────────────────────────────────────────────────
# main.tf — Entorno dev
# Orquesta todos los módulos para desplegar WordPress en ECS Fargate
# ─────────────────────────────────────────────────────────────────────────────

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ── Módulo: VPC ───────────────────────────────────────────────────────────────

module "vpc" {
  source = "../../modules/vpc"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  tags                 = local.common_tags
}

# ── Módulo: Security Groups ───────────────────────────────────────────────────

module "security_groups" {
  source = "../../modules/security_groups"

  name_prefix    = local.name_prefix
  vpc_id         = module.vpc.vpc_id
  wordpress_port = var.wordpress_port
  tags           = local.common_tags
}

# ── Módulo: ALB ───────────────────────────────────────────────────────────────

module "alb" {
  source = "../../modules/alb"

  name_prefix       = local.name_prefix
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.security_groups.alb_sg_id
  wordpress_port    = var.wordpress_port
  tags              = local.common_tags
}

# ── Módulo: RDS ───────────────────────────────────────────────────────────────

module "rds" {
  source = "../../modules/rds"

  name_prefix          = local.name_prefix
  private_subnet_ids   = module.vpc.private_subnet_ids
  rds_sg_id            = module.security_groups.rds_sg_id
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
  db_instance_class    = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
  tags                 = local.common_tags
}

# ── Módulo: EFS ───────────────────────────────────────────────────────────────

module "efs" {
  source = "../../modules/efs"

  name_prefix        = local.name_prefix
  private_subnet_ids = module.vpc.private_subnet_ids
  efs_sg_id          = module.security_groups.efs_sg_id
  tags               = local.common_tags
}

# ── Módulo: ECS ───────────────────────────────────────────────────────────────

module "ecs" {
  source = "../../modules/ecs"

  name_prefix        = local.name_prefix
  private_subnet_ids = module.vpc.private_subnet_ids
  ecs_sg_id          = module.security_groups.ecs_sg_id
  target_group_arn   = module.alb.target_group_arn
  efs_file_system_id = module.efs.efs_file_system_id

  wordpress_image = var.wordpress_image
  wordpress_port  = var.wordpress_port
  task_cpu        = var.task_cpu
  task_memory     = var.task_memory
  desired_count   = var.desired_count

  db_host     = module.rds.db_endpoint
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password

  aws_region = var.aws_region
  tags       = local.common_tags
}
