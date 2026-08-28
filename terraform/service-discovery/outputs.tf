output "namespace_id" {
  description = "Cloud Map private DNS namespace ID"
  value       = aws_service_discovery_private_dns_namespace.test.id
}

output "namespace_name" {
  description = "Cloud Map private DNS namespace name"
  value       = aws_service_discovery_private_dns_namespace.test.name
}

output "backend_service_id" {
  description = "Cloud Map backend service ID"
  value       = aws_service_discovery_service.nginx.id
}

output "backend_service_arn" {
  description = "Cloud Map backend service ARN"
  value       = aws_service_discovery_service.nginx.arn
}

output "backend_service_name" {
  description = "Cloud Map backend service name"
  value       = aws_service_discovery_service.nginx.name
}