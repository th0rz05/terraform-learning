provider "aws" {
  region = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_instance" "my-first-server"{
    ami = "ami-0360c520857e3138f"
    instance_type = "t3.micro"
}