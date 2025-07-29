variable "project" {
  description = "Project name used for tagging and naming resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the ALB and target group will be deployed"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with the ALB"
  type        = list(string)
}

variable "acm_certificate_arn" {
  description = "ARN of the existing ACM certificate for HTTPS"
  type        = string
}

variable "public_subnet_ids" {
  description = "Private subnet IDs for the ALB"
  type        = list(string)
}