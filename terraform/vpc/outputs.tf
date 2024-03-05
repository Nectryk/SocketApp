output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_info" {
  description = "Public Subnets IDs and AZs"
  value = [
    for subnet in aws_subnet.public_subnets : {
      id                = subnet.id
      availability_zone = subnet.availability_zone
    }
  ]
}

output "private_subnet_info" {
  description = "Private Subnets IDs and AZs"
  value = [
    for subnet in aws_subnet.private_subnets : {
      id                = subnet.id
      availability_zone = subnet.availability_zone
    }
  ]
}