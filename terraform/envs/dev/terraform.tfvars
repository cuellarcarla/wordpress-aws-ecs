# ── Configuración general ─────────────────────────────────────────────────────
aws_region   = "us-east-1"
project_name = "wordpress-ecs"
environment  = "dev"

# ── Red ───────────────────────────────────────────────────────────────────────
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
availability_zones   = ["us-east-1a", "us-east-1b"]

# ── ECS / WordPress ───────────────────────────────────────────────────────────
wordpress_image = "wordpress:6.5-php8.2-apache"
task_cpu        = 512
task_memory     = 1024
desired_count   = 2
wordpress_port  = 80

# ── RDS ───────────────────────────────────────────────────────────────────────
db_name              = "wordpress"
db_username          = "wpuser"
# db_password         → NO se pone aquí, se inyecta como secret en GitHub Actions
db_instance_class    = "db.t3.micro"
db_allocated_storage = 20
