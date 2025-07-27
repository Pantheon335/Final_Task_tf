/* output "subnet_ids" {
  description = "List of IDs of subnets from vpc"
  value       = module.network.subnet_ids
} */

output "alb_dns_name" {
  description = "DNS name from ALB"
  value       = module.alb.alb_dns_name
}