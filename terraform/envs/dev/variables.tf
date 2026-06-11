variable "aws_region" {
  description = "Región AWS donde desplegar la infraestructura"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre del proyecto, usado como prefijo en todos los recursos"
  type        = string
  default     = "wordpress-ecs"
}

variable "environment" {
  description = "Nombre del entorno (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# ── Red ──────────────────────────────────────────────────────────────────────

variable "vpc_cidr" {
  description = "CIDR block de la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDRs de las subredes públicas (una por AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs de las subredes privadas (una por AZ)"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "Zonas de disponibilidad a usar"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# ── ECS / WordPress ───────────────────────────────────────────────────────────

variable "wordpress_image" {
  description = "Imagen Docker de WordPress"
  type        = string
  default     = "wordpress:6.5-php8.2-apache"
}

variable "task_cpu" {
  description = "CPU units para la ECS Task (256 = 0.25 vCPU)"
  type        = number
  default     = 512
}

variable "task_memory" {
  description = "Memoria en MB para la ECS Task"
  type        = number
  default     = 1024
}

variable "desired_count" {
  description = "Número de tasks ECS a mantener corriendo"
  type        = number
  default     = 2
}

variable "wordpress_port" {
  description = "Puerto en el que escucha WordPress dentro del contenedor"
  type        = number
  default     = 80
}

# ── RDS ───────────────────────────────────────────────────────────────────────

variable "db_name" {
  description = "Nombre de la base de datos MySQL"
  type        = string
  default     = "wordpress"
}

variable "db_username" {
  description = "Usuario administrador de la base de datos"
  type        = string
  default     = "wpuser"
}

variable "db_password" {
  description = "Contraseña de la base de datos (inyectada como secret en GitHub Actions)"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "Tipo de instancia RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Almacenamiento en GB para RDS"
  type        = number
  default     = 20
}
