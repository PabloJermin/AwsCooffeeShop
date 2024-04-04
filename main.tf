terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.42.0"
    }
  }
}

# setting up the region and credentials
provider "aws" {
    region = var.my_region
    access_key = var.access_key
    secret_key = var.secret_key
}


# creating a vpc
resource "aws_vpc" "my_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = "true"
  enable_dns_support = "true"

  tags = {
    Name = "my_vpc"
  }
}


# creating a security group
resource "aws_security_group" "sec_g" {
  name        = "sec_g"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  tags = {
    Name = "sec_g"
  }
}


# the inbound security  rule
resource "aws_security_group_rule" "g_rule" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["192.168.0.0/16"]
  # ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  security_group_id = aws_security_group.sec_g.id
}


# public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  # availability_zone = var.my_region

  tags = {
    Name = "public_subnet"
  }
}


# private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
  # availability_zone = var.my_region

  tags = {
    Name = "private_subnet"
  }
}



# internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "main_gw"
  }
}


# route tables
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }


  tags = {
    Name = "my_route"
  }
}


# route association table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.rt.id
  # gateway_id = aws_internet_gateway.gw.id
}

# resource "aws_route_table_association" "b" {
#   gateway_id     = aws_internet_gateway.gw.id
#   route_table_id = aws_route_table.rt.id
# }



# public instance
resource "aws_instance" "pub_inst" {
  ami           = var.my_ami # us-east-1
  instance_type = var.my_instance
  vpc_security_group_ids = [ "${aws_security_group.sec_g.id}" ]
  subnet_id = aws_subnet.public_subnet.id
  user_data = <<-EOF
  #!/bin/bash
  echo "*** Installing apache2"
  sudo apt update -y
  sudo apt install apache2 -y
  echo "*** Completed Installing apache2"
  EOF

  tags = {
    Name = "web_instance"
  }
}

# private instance
resource "aws_instance" "pri_inst" {
  ami           = var.the_ami          # us-east-1
  instance_type = var.my_instance
  vpc_security_group_ids = [ "${aws_security_group.sec_g.id}" ]
  subnet_id = aws_subnet.private_subnet.id

  tags = {
    Name = "private_instance"
  }
}




