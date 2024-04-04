#Creating the VPC for the AWS serivces we will use
resource "aws_vpc" "main_VPC" {
  cidr_block       = "10.0.0.0/16"
  tags = {
    Name = "main VPC"
  }
}

#Creating a subnet for our VPC
resource "aws_subnet" "main_subnet" {
  vpc_id            = aws_vpc.main_VPC.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "main subnet"
  }
}

#Creating an internet gateway to allow the VPC to connect to internet
resource "aws_internet_gateway" "VPC_gateway" {
  vpc_id = aws_vpc.main_VPC.id

    tags = {
    Name = "internet door"
  }
}

#Creating Custom Route Table that allows all ports access to internet
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.VPC_gateway.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.VPC_gateway.id
  }

  tags = {
    Name = "Lenient Route Table"
  }
}

#Associating subnet to route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.route_table.id
}

#Creating a security group that allows all incoming and outgoing traffic
resource "aws_security_group" "allow_traffic" {
  name        = "allow_all_web_traffic"
  description = "Allow Web inbound and outbound traffic"
  vpc_id      = aws_vpc.main_VPC.id

  ingress {
    description = "All traffic into all ports"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description = "All traffic out of all ports"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_all_traffic"
  }
}

# Creating a network interface with an ip in the subnet
resource "aws_network_interface" "network-interface" {
  subnet_id       = aws_subnet.main_subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_traffic.id]

}

# An elastic IP is assigned to the network interface in order to be able to connect machines
resource "aws_eip" "eip" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.network-interface.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.VPC_gateway]
}

# A simple ec2 instance if you'd like to test the VP

# resource "aws_instance" "web-server-instance" {
#   ami               = "ami-0d7a109bf30624c99" # Image ami be changed in the future. May need to be replaced from AWS website
#   instance_type     = "t2.micro"
#   availability_zone = "us-east-1a"
#   key_name          = "main-key" # Grab a pem key-pair from AWS website and save it within ./Terraform

#   network_interface {
#     device_index         = 0
#     network_interface_id = aws_network_interface.network-interface.id
#   }

#   tags = {
#     Name = "web-server"
#   }
# }