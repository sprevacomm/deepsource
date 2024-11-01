resource "aws_security_group" "lb" {
  name        = "ELB Public Ingress"
  description = "ELB Public Ingress"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "elb_http_ingress" {
  security_group_id = aws_security_group.lb.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80

  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "elb_https_ingress" {
  security_group_id = aws_security_group.lb.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443

  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "elb_icmp_ingress" {
  security_group_id = aws_security_group.lb.id
  type              = "ingress"
  protocol          = "icmp"
  from_port         = -1
  to_port           = -1

  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "elb_outbound_cluster_ephemeral" {
  security_group_id = aws_security_group.lb.id
  type              = "egress"
  protocol          = "tcp"
  from_port         = 30000
  to_port           = 32767

  source_security_group_id = var.cluster_security_group_id
}

resource "aws_security_group_rule" "elb_outbound_cluster_icmp" {
  security_group_id = aws_security_group.lb.id
  type              = "egress"
  protocol          = "icmp"
  from_port         = -1
  to_port           = -1

  source_security_group_id = var.cluster_security_group_id
}

resource "aws_security_group_rule" "cluster_elb_ingress_ephemeral" {
  security_group_id = var.cluster_security_group_id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 30000
  to_port           = 32767

  source_security_group_id = aws_security_group.lb.id
}

resource "aws_security_group_rule" "cluster_elb_ingress_icmp" {
  security_group_id = var.cluster_security_group_id
  type              = "ingress"
  protocol          = "icmp"
  from_port         = -1
  to_port           = -1

  source_security_group_id = aws_security_group.lb.id
}

# Network Load Balancer for apiservers and ingress
resource "aws_lb" "alb" {
  name               = var.base_name
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  internal           = false
  idle_timeout       = 300

  subnets         = var.public_subnet_ids
  security_groups = [aws_security_group.lb.id]

  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true
}

# HTTP Redirect
resource "aws_lb_listener" "ingress_http" {
  load_balancer_arn = aws_lb.alb.arn
  protocol          = "HTTP"
  port              = 80

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS Ingress
resource "aws_lb_target_group" "ingress_https" {
  name_prefix          = "https-"
  port                 = 30080
  protocol             = "HTTP"
  deregistration_delay = 20
  vpc_id               = var.vpc_id

  health_check {
    path    = "/healthz"
    matcher = "200"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "wait" {
  certificate_arn = var.certificate_arn
}

resource "aws_lb_listener" "ingress_https" {
  load_balancer_arn = aws_lb.alb.arn
  protocol          = "HTTPS"
  port              = 443
  certificate_arn   = aws_acm_certificate_validation.wait.certificate_arn
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ingress_https.arn
  }
}

resource "aws_autoscaling_attachment" "ingress_https" {
  autoscaling_group_name = var.target_asg_name
  lb_target_group_arn    = aws_lb_target_group.ingress_https.arn
}

data "aws_route53_zone" "primary" {
  name = var.domain
  tags = {
    Stack = var.base_name
  }
}

# Main domain A record alias to ELB
resource "aws_route53_record" "a_record_alb_dns_name" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }

  lifecycle {
    ignore_changes = [zone_id]
  }
}

# Default wildcard subdomain alias to ELB
resource "aws_route53_record" "default_wildcard" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "*.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }

  lifecycle {
    ignore_changes = [zone_id]
  }
}

# Additional wildcard subdomains alias to ELB
resource "aws_route53_record" "additional_wildcards" {
  count   = length(var.wildcard_subdomains)
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "*.${var.wildcard_subdomains[count.index]}.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }

  lifecycle {
    ignore_changes = [zone_id]
  }
}
