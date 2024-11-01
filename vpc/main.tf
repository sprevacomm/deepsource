
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_region" "current" {}

locals {
  zone_ids   = data.aws_availability_zones.available.zone_ids
  zone_names = data.aws_availability_zones.available.names
  zone_count = min(length(data.aws_availability_zones.available.zone_ids), 3)
  region     = data.aws_region.current.name
}

#######
# VPC #
#######

resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = var.vpc_name
  }
}


###################
# Private Subnets #
###################

resource "aws_subnet" "private" {
  count                = local.zone_count
  availability_zone_id = local.zone_ids["${count.index}"]
  cidr_block           = "10.0.${count.index}.0/24"
  vpc_id               = aws_vpc.this.id
  tags = {
    Name                              = "private-${substr(local.zone_names["${count.index}"], -1, -1)}"
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_route_table" "private" {
  count  = local.zone_count
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public["${count.index}"].id
  }

  tags = {
    Name = "private-${substr(local.zone_names["${count.index}"], -1, -1)}"
  }
}

resource "aws_route_table_association" "public" {
  count          = local.zone_count
  subnet_id      = aws_subnet.public["${count.index}"].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = local.zone_count
  subnet_id      = aws_subnet.private["${count.index}"].id
  route_table_id = aws_route_table.private["${count.index}"].id
}


##################
# Public Subnets #
##################

resource "aws_subnet" "public" {
  count                   = local.zone_count
  availability_zone_id    = local.zone_ids["${count.index}"]
  cidr_block              = "10.0.${count.index + 4}.0/24"
  vpc_id                  = aws_vpc.this.id
  map_public_ip_on_launch = true
  tags = {
    Name                     = "public-${substr(local.zone_names["${count.index}"], -1, -1)}"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_nat_gateway" "public" {
  count             = local.zone_count
  connectivity_type = "public"
  subnet_id         = aws_subnet.public["${count.index}"].id
  allocation_id     = aws_eip.public["${count.index}"].id
}

resource "aws_eip" "public" {
  count  = local.zone_count
  domain = "vpc"
}


##################
# VPC Endpoints  #
##################

resource "aws_vpc_endpoint" "dynamodb" {
  service_name    = "com.amazonaws.${local.region}.dynamodb"
  vpc_id          = aws_vpc.this.id
  route_table_ids = concat([aws_route_table.public.id], aws_route_table.private[*].id)
  tags = {
    Name = "${var.vpc_name}-dynamodb"
  }
}

resource "aws_vpc_endpoint" "s3" {
  service_name    = "com.amazonaws.${local.region}.s3"
  vpc_id          = aws_vpc.this.id
  route_table_ids = concat([aws_route_table.public.id], aws_route_table.private[*].id)
  tags = {
    Name = "${var.vpc_name}-s3"
  }
}

resource "aws_vpc_endpoint" "sts" {
  service_name      = "com.amazonaws.${local.region}.sts"
  vpc_id            = aws_vpc.this.id
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.private[*].id
  tags = {
    Name = "${var.vpc_name}-sts"
  }
}

resource "aws_vpc_endpoint" "kinesis-streams" {
  service_name      = "com.amazonaws.${local.region}.kinesis-streams"
  vpc_id            = aws_vpc.this.id
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.private[*].id
  tags = {
    Name = "${var.vpc_name}-kinesis-streams"
  }
}


########################
# EC2 Instance Connect #
########################

resource "aws_key_pair" "default" {
  key_name   = var.vpc_name
  public_key = var.ec2_public_key
}

resource "aws_ec2_instance_connect_endpoint" "ec2_instance_connect" {
  subnet_id          = aws_subnet.public[0].id
  preserve_client_ip = false
  security_group_ids = [aws_security_group.ec2_instance_connect.id]
}

resource "aws_security_group" "ec2_instance_connect" {
  name        = "ec2-instance-connect-sg"
  description = "EC2 Instance Connect"
  vpc_id      = aws_vpc.this.id
  tags = {
    Name = "ec2-instance-connect-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "ssh_outbound" {
  security_group_id = aws_security_group.ec2_instance_connect.id
  cidr_ipv4         = aws_vpc.this.cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
