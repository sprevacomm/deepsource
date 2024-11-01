resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "Bastion security group, SSM needs egress only"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.bastion.id
  description       = "Egress"
  type              = "egress"
  protocol          = "tcp"
  from_port         = 0
  to_port           = 65535
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "instance_connect" {
  security_group_id        = aws_security_group.bastion.id
  description              = "Instance Connect Ingress"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 22
  to_port                  = 22
  source_security_group_id = var.ec2_instance_connect_sg
}
