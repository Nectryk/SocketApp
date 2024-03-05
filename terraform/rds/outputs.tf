output "db_endpoint" {
  description = "Endpoint of the RDS MySQL DB"
  value       = aws_db_instance.db_mysql.endpoint
}

output "sg_db_id" {
  description = "ID of the SG for the DB instance"
  value       = aws_security_group.db_sg.id
}