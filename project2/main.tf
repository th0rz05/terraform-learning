provider "aws" {
  region = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# 1. Create vpc
resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "MyVPC"
  }
}

# 2. Create Internet Gateway
resource "aws_internet_gateway" "prod-igw" {
  vpc_id = aws_vpc.prod-vpc.id

  tags = {
    Name = "MyInternetGateway"
  }
}

# 3. Create Custom Route Table
resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.prod-vpc.id

  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod-igw.id
  }

  tags = {
    Name = "MyRouteTable"
  }

}
# 4. Create a Subnet
resource "aws_subnet" "prod-subnet" {
  vpc_id     = aws_vpc.prod-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "MySubnet"
  }

}
# 5. Associate Route Table with Subnet
resource "aws_route_table_association" "prod-route-table-association" {
  subnet_id      = aws_subnet.prod-subnet.id
  route_table_id = aws_route_table.prod-route-table.id
}

# 6. Create a Security Group to allow port 22,80,443
resource "aws_security_group" "prod-security-group" {
  name   = "allow_web_traffic"
  description = "Allow web traffic"
  vpc_id = aws_vpc.prod-vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
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
    Name = "MySecurityGroup"
  }
}

# 7. Create a network interface with an ip in the subnet created in step 4
resource "aws_network_interface" "prod-network-interface" {
  subnet_id = aws_subnet.prod-subnet.id
  private_ips = ["10.0.1.50"]
  security_groups = [aws_security_group.prod-security-group.id]

  tags = {
    Name = "MyNetworkInterface"
  }
}

# 8. Assign an elastic IP to the network interface created in step 7
resource "aws_eip" "prod-elastic-ip" {
  domain                   = "vpc"
  network_interface        = aws_network_interface.prod-network-interface.id
  associate_with_private_ip = "10.0.1.50"
  depends_on               = [
    aws_internet_gateway.prod-igw,
    aws_instance.prod-ubuntu
  ]
}


# 9. Create Ubuntu server and install/enable apache2
resource "aws_instance" "prod-ubuntu" {
    ami = "ami-0360c520857e3138f"
    instance_type = "t3.micro"
    availability_zone = "us-east-1a"
    key_name = "main-key"
    primary_network_interface {
      network_interface_id = aws_network_interface.prod-network-interface.id
    }
    tags = {
      Name = "MyUbuntuServer"
    }

    user_data = <<-EOF
                #!/bin/bash
                apt-get update
                apt-get install -y apache2
                systemctl start apache2
                sudo bash -c "echo '<h1>Hello, World!</h1>' > /var/www/html/index.html"
                EOF
}
