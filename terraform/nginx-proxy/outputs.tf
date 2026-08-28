output "proxy_service_name" {
  value = aws_ecs_service.nginx_proxy.name
}

output "proxy_task_definition" {
  value = aws_ecs_task_definition.nginx_proxy.arn
}