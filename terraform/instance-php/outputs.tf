output "alb_public_dns" {
  description = "Public DNS of the load balancer"
  value       = aws_lb.web_app_lb.dns_name
}

output "sg_web_id" {
  description = "ID of the Web App SG"
  value       = aws_security_group.sg_web_server.id
}