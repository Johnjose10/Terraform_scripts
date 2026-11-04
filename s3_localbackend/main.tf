terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" # Change to your preferred AWS region
}

# 1. Create the S3 Bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "johnjose-terraform-s3-2026-1102" # Must be globally unique

  tags = {
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}

# 2. (Optional) Enable Versioning
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.my_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 3. (Optional) Block Public Access (Recommended for security)
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket                  = aws_s3_bucket.my_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
