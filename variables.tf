#Network

variable "vpc_cidr" {
  description = "Network subnet"
  type        = string
}

#Route 53

variable "root_domain" {
  description = "Root domain"
  type        = string
}

variable "project" {
  description = "Name of the project"
  type        = string
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR"
  type        = string
}

variable "private_subnet_cidr" {
  description = "Private subnet CIDR"
  type        = string
}

variable "subdomain" {
  description = "Subdomain (to be created)"
  type        = string
}

variable "aws_region" {
  description = "Region to use"
  type        = string
}

variable "db_password" {
  description = "Database master password"
  sensitive   = true
}
