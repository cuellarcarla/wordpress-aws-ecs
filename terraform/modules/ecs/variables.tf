variable "name_prefix" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "ecs_sg_id" { type = string }
variable "target_group_arn" { type = string }
variable "efs_file_system_id" { type = string }

variable "wordpress_image" { type = string }
variable "wordpress_port" { type = number; default = 80 }
variable "task_cpu" { type = number }
variable "task_memory" { type = number }
variable "desired_count" { type = number; default = 2 }

variable "db_host" { type = string }
variable "db_name" { type = string }
variable "db_username" { type = string }
variable "db_password" { type = string; sensitive = true }

variable "aws_region" { type = string }
variable "tags" { type = map(string); default = {} }
