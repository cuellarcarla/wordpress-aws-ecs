output "alb_sg_id" {
  description = "ID del Security Group del ALB"
  value       = aws_security_group.alb.id
}

output "ecs_sg_id" {
  description = "ID del Security Group de ECS"
  value       = aws_security_group.ecs.id
}

output "rds_sg_id" {
  description = "ID del Security Group de RDS"
  value       = aws_security_group.rds.id
}

output "efs_sg_id" {
  description = "ID del Security Group de EFS"
  value       = aws_security_group.efs.id
}
