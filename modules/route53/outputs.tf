output "zone_id" {
  value       = data.aws_route53_zone.this.zone_id
  description = "The ID of the Route 53 hosted zone."
}

output "fqdn" {
  value       = "${var.subdomain}.${var.root_domain}"
  description = "FQDN for the subdomain"
}

output "record_name" {
  value       = aws_route53_record.subdomain.name
  description = "The subdomain record name"
}