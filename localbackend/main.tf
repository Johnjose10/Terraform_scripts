provider "aws" {
  region = var.region
}

# Grab your default AWS VPC
data "aws_vpc" "default" {
  default = true
}

# Simple security group for SSH, HTTP, and HTTPS
resource "aws_security_group" "sg" {
  name   = "web-ssh-sg"
  vpc_id = data.aws_vpc.default.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic so the VM can reach the internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# The Virtual Machine
resource "aws_instance" "vm" {
  ami                         = var.ami
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "SimpleVM"
  }
}
