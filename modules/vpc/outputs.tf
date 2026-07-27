output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.gw.id
}

output "subnet_ids" {
  description = "Map of subnet names to subnet IDs"
  value       = { for k, v in aws_subnet.subnet : k => v.id }
}

output "nat_gateway_ids" {
  description = "Map of public subnet names to NAT Gateway IDs"
  value       = { for k, v in aws_nat_gateway.nat : k => v.id }
}
