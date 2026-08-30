output "namespace_id" {
  description = "Cloud Map private DNS namespace ID"
  value       = aws_service_discovery_private_dns_namespace.backend.id
}

output "namespace_name" {
  description = "Cloud Map private DNS namespace name"
  value       = aws_service_discovery_private_dns_namespace.backend.name
}

output "nginx1_service_arn" {
  description = "Cloud Map nginx1 service ARN"
  value       = aws_service_discovery_service.nginx1.arn
}

output "nginx2_service_arn" {
  description = "Cloud Map nginx2 service ARN"
  value       = aws_service_discovery_service.nginx2.arn
}