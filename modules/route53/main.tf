data "aws_route53_zone" "this" {
  name         = var.root_domain
  private_zone = false
}

resource "aws_route53_record" "subdomain" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.subdomain
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }  
}