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
  region = "us-east-1"
}

resource "aws_dynamodb_table" "basic_table" {
  name         = "AppStorage"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id" # Mandatory partition key placeholder

  attribute {
    name = "id"
    type = "S" # String type (can hold UUIDs, auto-generated IDs, etc.)
  }
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.basic_table.name
  description = "The name of the DynamoDB table"
}
