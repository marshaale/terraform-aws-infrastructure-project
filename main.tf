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

resource "aws_security_group" "sg" {
  name_prefix = "azm-sg-"
  description = "Allows incoming http, https and ssh traffic"
  vpc_id = aws_vpc.amz_vpc.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "amazon_security_group"
    Environment = "production"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.sg.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port = 80
  to_port = 80
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.sg.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port = 443
  to_port = 443
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.sg.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port = 22
  to_port = 22
}

resource "aws_s3_bucket" "s3bucket" {
  bucket = var.bucket_name
  tags = {
    Name = "amazon_s3_bucket"
    Environment = "production"
  }
}

resource "aws_s3_bucket_public_access_block" "s3bucket" {
  bucket = aws_s3_bucket.s3bucket.id
  
  block_public_acls = true
  ignore_public_acls = true
  block_public_policy = true
  restrict_public_buckets = true
}

resource "aws_instance" "server1" {
  ami = "ami-0c7632fb77f35db43"
  key_name = var.ssh_key_name
  instance_type = "t3.micro"
  subnet_id = aws_subnet.pubs1.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  user_data_base64 = base64encode(file("script.sh"))
  tags = {
    Name = "server 1"
    Environment = "production"
  }
}

resource "aws_instance" "server2" {
  ami = "ami-0c7632fb77f35db43"
  key_name = var.ssh_key_name
  instance_type = "t3.micro"
  subnet_id = aws_subnet.pubs2.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  user_data_base64 = base64encode(file("script.sh"))
  tags = {
    Name = "server 2"
    Environment = "production"
  }
}

resource "aws_lb" "aplb" {
  load_balancer_type = "application"
  ip_address_type = "IPv4"
  internal = false
  security_groups = [aws_security_group.sg.id]
  subnets = [aws_subnet.pubs1.id,aws_subnet.pubs2.id]
  tags = {
    Name = "amazon application load balancer"
    Environment = "production"
  }
}

resource "aws_lb_target_group" "aplbtg" {
  port        = 80
  protocol    = "HTTP"
  target_type = "instances"
  vpc_id      = aws_vpc.amz_vpc.id
  ip_address_type = "IPv4"
  protocol_version = "HTTP1"
  tags = {
    Name = "amazon application load balancer target group"
    Environment = "production"
  }
}

resource "aws_lb_target_group_attachment" "tgs1" {
  target_id = aws_instance.server1.id
  target_group_arn = aws_lb_target_group.aplbtg.arn
  port = 80
}

resource "aws_lb_target_group_attachment" "tgs2" {
  target_id = aws_instance.server2.id
  target_group_arn = aws_lb_target_group.aplbtg.arn
  port = 80
}

resource "aws_lb_listener" "lbls" {
  load_balancer_arn = aws_lb.aplb.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.aplbtg.arn
  }
  tags = {
    Name = "amazon application load balancer listener"
    Environment = "production"
  }
}