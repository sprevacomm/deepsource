resource "aws_instance" "bastion" {
  ami           = data.aws_ami.al2023.id
  instance_type = var.instance_type

  subnet_id              = element(var.private_subnet_ids, 0)
  vpc_security_group_ids = [aws_security_group.bastion.id]
  user_data = templatefile("${path.module}/files/init.sh", {
    HELM_VERSION      = var.helm_version
    TERRAFORM_VERSION = var.terraform_version
    KUBECTL_VERSION   = var.kubectl_version
  })
  user_data_replace_on_change = true
  key_name                    = var.ec2_ssh_key

  root_block_device {
    volume_type = "gp3"
    volume_size = 8
    encrypted   = true
    kms_key_id  = aws_kms_key.bastion.arn
  }

  lifecycle {
    ignore_changes = [
      ami, # Don't rebuild the server just because a new base image is available
    ]
  }
  tags = {
    Name = "${var.base_name}-bastion"
  }
}

data "aws_ami" "al2023" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-kernel-6.1-x86_64"]
  }
}

resource "aws_kms_key" "bastion" {
  description = "KMS key for encrypting the root volume of the bastion server"
}

resource "aws_kms_alias" "bastion" {
  name          = "alias/${var.base_name}-bastion"
  target_key_id = aws_kms_key.bastion.key_id
}
