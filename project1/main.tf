provider "aws" {
  region = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# resource "aws_instance" "my-first-server"{
#     ami = "ami-0360c520857e3138f"
#     instance_type = "t3.micro"
#     tags = {
#       Name = "MyFirstServer"
#     }
# }

resource "aws_vpc" "first-vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "FirstVPC"
  }
}

resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.first-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "FirstSubnet"
  }
}