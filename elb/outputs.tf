output "elb_dns_name" {
  description = "The DNS name of the ELB"
  value       = aws_lb.alb.dns_name
}

output "elb_zone_id" {
  description = "The zone_id of the ELB"
  value       = aws_lb.alb.zone_id
}
