output "db_endpoint" {
  description = "Endpoint de conexion a RDS (sin puerto)"
  value       = aws_db_instance.wordpress.address
  sensitive   = true
}

output "db_port" {
  value = aws_db_instance.wordpress.port
}
