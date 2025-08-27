provider "aws" {
  region = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# 1. Create vpc
# 2. Create Internet Gateway
# 3. Create Custom Route Table
# 4. Create a Subnet
# 5. Associate Route Table with Subnet
# 6. Create a Security Group to allow port 22,80,443
# 7. Create a network interface with an ip in the subnet created in step 4
# 8. Assign an elastic IP to the network interface created in step 7
# 9. Create Ubuntu server and install/enable apache2