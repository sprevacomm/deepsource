output "global_acm_certificate_arn" {
  description = "The ARN of the Global ACM certificate"
  value       = local.global_acm_certificate_arn
}

output "acm_certificate_arn" {
  description = "The ARN of the ACM certificate"
  value       = aws_acm_certificate.this.arn
}

output "acm_certificate_domain" {
  description = "The domain name of the ACM certificate"
  value       = aws_acm_certificate.this.domain_name
}

output "acm_certificate_sans" {
  description = "The subject alternative names of the ACM certificate"
  value       = aws_acm_certificate.this.subject_alternative_names
}

output "zone_id" {
  value = aws_route53_zone.self.id
}
