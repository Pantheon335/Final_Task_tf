variable "project" {}
variable "cluster_id" {}
variable "execution_role_arn" {}
variable "frontend_image_url" {}
variable "backend_image_url" {}
variable "private_subnet_ids" { type = list(string) }
variable "security_group_ids" { type = list(string) }
variable "alb_frontend_tg_arn" {}
variable "alb_backend_tg_arn" {}