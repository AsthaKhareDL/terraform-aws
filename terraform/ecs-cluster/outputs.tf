output "ecs_cluster_id" {
  description = "ECS cluster ARN"
  value       = aws_ecs_cluster.example.id
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.example.name
}

output "ecs_security_group_id" {
  description = "Security group ID used by ECS EC2 instances"
  value       = aws_security_group.ecs_instance.id
}

output "ecs_asg_name" {
  description = "ECS Auto Scaling Group name"
  value       = aws_autoscaling_group.ecs.name
}