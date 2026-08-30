output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of public subnet 1"
  value       = aws_subnet.public.id
}

output "public_subnet_2_id" {
  description = "ID of public subnet 2"
  value       = aws_subnet.public_2.id
}

output "public_subnet_ids" {
  description = "IDs of both public subnets"
  value = [
    aws_subnet.public.id,
    aws_subnet.public_2.id
  ]
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

