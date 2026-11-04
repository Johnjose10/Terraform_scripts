variable "region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "ami" {
  default = "ami-073f45061d35c86f0" # Amazon Linux 2023 (us-east-1)
}
