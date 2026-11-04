
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# 1. VARIABLES

variable "region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "ami" {
  default = "ami-0c7217cdde317cfec"
}

# 2. AWS PROVIDER

provider "aws" {
  region = var.region
}

# 3. DEFAULT VPC

data "aws_vpc" "default" {
  default = true
}

# 4. SECURITY GROUP

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

  # OUTBOUND TRAFFIC
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-ssh-sg"
  }
}

# 5. EC2 INSTANCE

resource "aws_instance" "vm" {
  ami                         = var.ami
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "SimpleVM"
  }
}

# 6. S3 BUCKET

resource "aws_s3_bucket" "my_bucket" {
  bucket = "johnjose-terraform-lab-2026-unique12345"

  tags = {
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}

# 7. S3 VERSIONING

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.my_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# 8. S3 PUBLIC ACCESS BLOCK

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket                  = aws_s3_bucket.my_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 9. DYNAMODB TABLE

resource "aws_dynamodb_table" "basic_table" {
  name         = "AppStorage"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}

# 10. OUTPUTS

output "ec2_public_ip" {
  value = aws_instance.vm.public_ip
}

output "ec2_instance_id" {
  value = aws_instance.vm.id
}

output "s3_bucket_name" {
  value = aws_s3_bucket.my_bucket.id
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.basic_table.name
}

