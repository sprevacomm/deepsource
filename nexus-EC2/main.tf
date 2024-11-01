# Get latest AWS Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# EC2 Instance Security Group
resource "aws_security_group" "nexus_sg" {
  name        = "${var.name_prefix}-nexus-sg"
  description = "Security group for Nexus instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 8081
    to_port         = 8081
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
    description     = "Allow Nexus port from ALB"
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.ec2_instance_connect_sg]
    description     = "Instance Connect Ingress"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nexus-sg"
  })
}


# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "${var.name_prefix}-alb-sg"
  description = "Security group for Nexus ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nexus-alb-sg"
  })
}

# Generate random password for Nexus admin
resource "random_password" "admin_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  min_special      = 2
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
}

# EC2 Instance
resource "aws_instance" "nexus" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  subnet_id     = var.private_subnet_ids[0]
  key_name      = var.name_prefix

  user_data = base64encode(templatefile("${path.module}/templates/userdata.sh", {
    NEW_ADMIN_PASSWORD = random_password.admin_password.result
  }))

  vpc_security_group_ids = [aws_security_group.nexus_sg.id]

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  lifecycle {
    ignore_changes = [
      ami
    ]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nexus"
  })
}

# Application Load Balancer
resource "aws_lb" "nexus" {
  name               = "${var.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nexus-alb"
  })
}

# ALB Listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.nexus.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nexus.arn
  }
}

# Target Group
resource "aws_lb_target_group" "nexus" {
  name     = "${var.name_prefix}-tg"
  port     = 8081
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/service/rest/v1/status"
    port                = "traffic-port"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nexus-tg"
  })
}

# Target Group Attachment
resource "aws_lb_target_group_attachment" "nexus" {
  target_group_arn = aws_lb_target_group.nexus.arn
  target_id        = aws_instance.nexus.id
  port             = 8081
}

# Route 53 Record
resource "aws_route53_record" "nexus" {
  zone_id = var.route53_zone_id
  name    = "nexus.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.nexus.dns_name
    zone_id                = aws_lb.nexus.zone_id
    evaluate_target_health = true
  }
}
