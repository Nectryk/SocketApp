output "instance_server_id" {
  description = "ID of the node Server instance"
  value       = aws_instance.node_server_instance.id
}

output "instance_server_private_ip" {
  description = "IP of the node server"
  value       = aws_instance.node_server_instance.private_ip
}

output "sg_node_server_id" {
  description = "ID of the node Server SG"
  value       = aws_security_group.sg_node_server.id
}

output "instance_client_id" {
  description = "IDs of the node Client instance"
  value       = aws_instance.node_client_instance[*].id
}

output "instance_client_private_ip" {
  description = "IPs of the node client"
  value       = aws_instance.node_client_instance[*].private_ip
}

output "sg_node_client_id" {
  description = "ID of the node Client SG"
  value       = aws_security_group.sg_node_client.id
}