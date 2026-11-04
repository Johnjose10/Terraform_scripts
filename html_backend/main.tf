terraform {
  required_version = ">= 1.0"

  # PASTE THIS IN NOW:
  backend "s3" {
    bucket         = "208812824960-terraform-states"
    key            = "global/new-s3-backend/terraform.tfstate"
    region         = "ap-south-1"
    use_lockfile   = true
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}
provider "aws" {
  region = "ap-south-1" # Change to your preferred AWS region
}

# 1. Create a Security Group allowing HTTP and SSH traffic
resource "aws_security_group" "web_sg" {
  name        = "web-server"
  description = "Allow HTTP and SSH inbound traffic"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-server"
  }
}

# 2. Provision the EC2 Instance with User Data to install Nginx and deploy index.html
resource "aws_instance" "web_server" {
  ami           = "ami-0f19324397f53458f" # Amazon Linux 2023 AMI (ap-south-1). Update if using another region.
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # User data script runs on first boot
  user_data = <<-EOF
              #!/bin/bash
              # Update system packages
              dnf update -y

              # Install Nginx
              dnf install -y nginx

              # Start and enable Nginx service
              systemctl start nginx
              systemctl enable nginx

              # Create a custom index.html page
              echo "<html>
                <head>
                  <title>Welcome to Terraform</title>
                </head>
                <body style='font-family: Arial, sans-serif; text-align: center; margin-top: 50px;'>
                  <h1>Hello from AWS EC2!</h1>
                  <p>Provisioned automatically using <strong>Terraform</strong> and Nginx.</p>
                </body>
              </html>" > /usr/share/nginx/html/index.html
              EOF

  tags = {
    Name = "Terraform-Nginx-Server"
  }
}

# 3. Output the public IP to access the web server
output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.web_server.public_ip
}

output "website_url" {
  description = "URL to access the Nginx welcome page"
  value       = "http://${aws_instance.web_server.public_ip}"
}
