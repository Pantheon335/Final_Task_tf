output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.application_lb.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the ALB"
  value       = aws_lb.application_lb.zone_id
}

output "alb_arn" {
  description = "The ARN of the ALB"
  value       = aws_lb.application_lb.arn
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.frontend_tg.arn
}

output "frontend_tg_arn" {
  value = aws_lb_target_group.frontend_tg.arn
}

output "backend_tg_arn" {
  value = aws_lb_target_group.backend_tg.arn
}