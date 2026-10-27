resource "aws_vpc" "amz_vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    instance_tenancy = "default"
    tags = {
      Name = "amazon_vpc"
      Environment = "production"
    }
}

resource "aws_subnet" "pubs1" {
    vpc_id = aws_vpc.amz_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-south-1a"
    map_public_ip_on_launch = true
    tags = {
      Name = "amazon-public-subnet-1"
      Environment = "production"
    }
}

resource "aws_subnet" "pubs2" {
  vpc_id = aws_vpc.amz_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "amazon-public-subnet-2"
    Environment = "production"
  }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.amz_vpc.id
    tags = {
      Name = "amazon_internet_gateway"
      Environment = "production"
    }
}

resource "aws_route_table" "pubrt" {
    vpc_id = aws_vpc.amz_vpc.id
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
      Name = "amazon_public_route_table"
      Environment = "production"
    }
}

resource "aws_route_table_association" "rtapubs1" {
  subnet_id      = aws_subnet.pubs1.id
  route_table_id = aws_route_table.pubrt.id
}

resource "aws_route_table_association" "rtapubs2" {
  subnet_id      = aws_subnet.pubs2.id
  route_table_id = aws_route_table.pubrt.id
}