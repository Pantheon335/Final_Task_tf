/* terraform {
  required_version = ">= 1.12.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.76"
    }
}
  backend "s3" {
    bucket         = "brukhy-terraform-state"    # Your S3 bucket name
    key            = "envs/prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "brukhy-terraform-locks"    # Optional for state locking
  }
}

provider "aws" {
  region = var.aws_region
} */

module "vpc" {
  source              = "./modules/vpc"
  project             = "brukhy"
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidr  = "10.0.1.0/24"
  private_subnet_cidr = "10.0.11.0/24"
}

module "security_groups" {
  source  = "./modules/security_groups"
  vpc_id  = module.vpc.vpc_id
  project = var.project
}

module "dns" {
  root_domain  = var.root_domain
  source       = "./modules/route53"
  subdomain    = var.subdomain
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id
  db_address   = module.rds.db_address
}
data "aws_route53_zone" "root" {
  name         = var.root_domain
  private_zone = false
}

module "acm" {
  source      = "./modules/acm"
  domain_name = local.fqdn
  zone_id     = data.aws_route53_zone.root.zone_id
}
locals {
  fqdn = "${var.subdomain}.${var.root_domain}"
}

module "alb" {
  source  = "./modules/alb"
  project = var.project
  vpc_id  = module.vpc.vpc_id
  #  private_subnet_ids  = module.vpc.private_subnet_ids
  public_subnet_ids   = module.vpc.public_subnet_ids
  security_group_ids  = [module.security_groups.alb_sg_id]
  acm_certificate_arn = module.acm.certificate_arn
}

module "ecr_frontend" {
  source = "./modules/ecr"
  name   = "${var.project}-frontend"
}

module "ecr_backend" {
  source = "./modules/ecr"
  name   = "${var.project}-backend"
}

module "ecs_cluster" {
  source  = "./modules/ecs_cluster"
  project = var.project
}

module "iam" {
  source  = "./modules/iam"
  project = var.project
}

module "ecs_services" {
  source              = "./modules/ecs_services"
  project             = var.project
  cluster_id          = module.ecs_cluster.id
  execution_role_arn  = module.iam.execution_role_arn
  frontend_image_url  = module.ecr_frontend.repository_url
  backend_image_url   = module.ecr_backend.repository_url
  private_subnet_ids  = module.vpc.private_subnet_ids
  security_group_ids  = [module.security_groups.ecs_sg_id]
  alb_frontend_tg_arn = module.alb.frontend_tg_arn
  alb_backend_tg_arn  = module.alb.backend_tg_arn
  frontend_sg_id      = module.security_groups.frontend_sg_id
  backend_sg_id       = module.security_groups.backend_sg_id
  task_role_arn       = module.iam.ecs_task_execution_role_arn

  depends_on = [
    module.alb,
  ]
}

module "rds" {
  source             = "./modules/rds"
  project            = var.project
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  db_name            = "projectdb"
  db_username        = "dbadmin"
  db_password        = var.db_password
  instance_class     = "db.t3.micro"
  allocated_storage  = 20
  security_group_ids = [module.security_groups.db_sg_id]
}

resource "aws_cloudwatch_log_group" "backend_logs" {
  name              = "/ecs/backend-task"
  retention_in_days = 7
}