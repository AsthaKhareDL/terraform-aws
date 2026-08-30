output "alb_id" {
  description = "Internal ALB ID"
  value       = aws_lb.internal.id
}

output "alb_arn" {
  description = "Internal ALB ARN"
  value       = aws_lb.internal.arn
}

output "alb_dns_name" {
  description = "Internal ALB DNS name"
  value       = aws_lb.internal.dns_name
}

output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = aws_security_group.alb.id
}

output "nginx1_target_group_arn" {
  description = "nginx1 target group ARN"
  value       = aws_lb_target_group.nginx1.arn
}

output "nginx2_target_group_arn" {
  description = "nginx2 target group ARN"
  value       = aws_lb_target_group.nginx2.arn
}

