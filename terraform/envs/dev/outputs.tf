output "alb_dns_name" {
  description = "URL pública del ALB para acceder a WordPress"
  value       = "http://${module.alb.alb_dns_name}"
}

output "alb_arn" {
  description = "ARN del Application Load Balancer"
  value       = module.alb.alb_arn
}

output "rds_endpoint" {
  description = "Endpoint interno de RDS MySQL"
  value       = module.rds.db_endpoint
  sensitive   = true
}

output "ecs_cluster_name" {
  description = "Nombre del ECS Cluster"
  value       = module.ecs.ecs_cluster_name
}

output "ecs_service_name" {
  description = "Nombre del ECS Service"
  value       = module.ecs.ecs_service_name
}

output "efs_file_system_id" {
  description = "ID del sistema de ficheros EFS (wp-content)"
  value       = module.efs.efs_file_system_id
}

output "vpc_id" {
  description = "ID de la VPC"
  value       = module.vpc.vpc_id
}
