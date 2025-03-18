locals {
  debian_ami_id = data.aws_ami.debian.id
}

data "local_file" "ssh_public_key" {
  filename = pathexpand("~/.ssh/id_rsa.pub")
}

data "aws_ami" "debian" {
  most_recent = true
  owners      = ["136693071363"] # Debian

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "spot_instances" {
  name        = "${var.project_name}-sg"
  description = "Security group for spot instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr
    description = "SSH access"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow all traffic between instances"
  }
  ingress {
    from_port   = 15672
    to_port     = 15672
    cidr_blocks = var.allowed_ssh_cidr
    protocol    = "tcp"
    self        = true
    description = "Expose rabbitmq interface"
  }

  # Saída para internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

module "debian_instances" {
  source = "./modules/spot-instance"
  count  = var.debian_instance_count

  name               = "rabbitmq-node-${count.index + 1}"
  ami_id             = local.debian_ami_id
  instance_type      = var.debian_instance_type
  key_name           = var.key_name
  subnet_id          = element(var.subnet_ids, count.index % length(var.subnet_ids))
  security_group_ids = [aws_security_group.spot_instances.id]
  spot_price         = var.spot_price
  root_volume_size   = var.root_volume_size
  user_data          = <<-EOF
    #!/bin/bash
    hostnamectl set-hostname rabbitmq-node-${count.index + 1}
    apt-get update

    mkdir -p /root/.ssh
    chmod 700 /root/.ssh
    echo "${data.local_file.ssh_public_key.content}" >> /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
  EOF

  tags = {
    Name      = "rabbitmq-node-${count.index + 1}"
    OS        = "Debian"
    OSVersion = "12"
    Project   = "spot-cluster"
    Cluster   = "nodes"
  }
}

module "debian_instances_master" {
  source = "./modules/spot-instance"
  count  = var.debian_instance_master_count

  name               = "rabbitmq-master-${count.index + 1}"
  ami_id             = local.debian_ami_id
  instance_type      = var.debian_instance_type
  key_name           = var.key_name
  subnet_id          = element(var.subnet_ids, count.index % length(var.subnet_ids))
  security_group_ids = [aws_security_group.spot_instances.id]
  spot_price         = var.spot_price
  root_volume_size   = var.root_volume_size
  user_data          = <<-EOF
    #!/bin/bash
    hostnamectl set-hostname rabbitmq-master-${count.index + 1}
    apt-get update

    mkdir -p /root/.ssh
    chmod 700 /root/.ssh
    echo "${data.local_file.ssh_public_key.content}" >> /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
  EOF

  tags = {
    Name      = "rabbitmq-master-${count.index + 1}"
    OS        = "Debian"
    OSVersion = "12"
    Project   = "spot-cluster"
    Cluster   = "master"
  }
}
