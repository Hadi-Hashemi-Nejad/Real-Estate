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
    Name = "Lenient Rout Table"
  }
}

#Associating subnet to route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.route_table.id
}