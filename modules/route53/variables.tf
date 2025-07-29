variable "alb_dns_name" {
  description = "ALB's domain name"
  type        = string
}

variable "alb_zone_id" {
  type        = string
  description = "Zone ID of the Application Load Balancer"
}

variable "root_domain" {
  description = "Root domain"
  type        = string
}

variable "subdomain" {
  description = "Subdomain (to be created)"
  type        = string
}

variable "db_address" {
  description = "Database endpoint (address)"
  type        = string
}