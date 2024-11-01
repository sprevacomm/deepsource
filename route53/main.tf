locals {
  subject_alternative_names = concat(
    ["*.${var.domain}"],
    [for subdomain in var.wildcard_subdomains : "*.${subdomain}.${var.domain}"]
  )

  global_acm_certificate_arn = data.aws_region.current.name == "us-east-1" ? aws_acm_certificate.this.arn : aws_acm_certificate.global[0].arn
}

resource "aws_route53_zone" "self" {
  name = var.domain
}

# Get the current region
data "aws_region" "current" {}

# Global (us-east-1) AWS ACM Certificate for the domain and all wildcard subdomains
# Only create when the current region us not us-east-1
resource "aws_acm_certificate" "global" {
  count             = data.aws_region.current.name != "us-east-1" ? 1 : 0
  provider          = aws.us-east-1
  domain_name       = var.domain
  validation_method = "DNS"

  subject_alternative_names = local.subject_alternative_names

  lifecycle {
    create_before_destroy = true
  }
}

# AWS ACM Certificate for the domain and all wildcard subdomains
resource "aws_acm_certificate" "this" {
  domain_name       = var.domain
  validation_method = "DNS"

  subject_alternative_names = local.subject_alternative_names

  lifecycle {
    create_before_destroy = true
  }
}

# DNS validation for the domain and all wildcard subdomains
resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.self.zone_id
}

data "aws_route53_zone" "root" {
  provider = aws.parent

  name = var.root_domain
}

resource "aws_route53_record" "root" {
  provider = aws.parent

  allow_overwrite = true
  zone_id         = data.aws_route53_zone.root.zone_id
  name            = var.domain
  type            = "NS"
  ttl             = 60
  records         = aws_route53_zone.self.name_servers
}
