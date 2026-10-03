resource "aws_vpc" "tarkin" {
  cidr_block           = "10.202.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "tarkin-vpc" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.tarkin.id
  cidr_block              = "10.202.0.0/24"
  availability_zone       = "eu-west-3a"
  map_public_ip_on_launch = false
  tags                    = { Name = "tarkin-public" }
}

resource "aws_internet_gateway" "tarkin" {
  vpc_id = aws_vpc.tarkin.id
  tags   = { Name = "tarkin-igw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.tarkin.id
  tags   = { Name = "tarkin-public" }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tarkin.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "lighthouse" {
  name        = "tarkin-lighthouse"
  description = "Nebula lighthouse only; SSH is available only through an SSM tunnel"
  vpc_id      = aws_vpc.tarkin.id
  tags        = { Name = "tarkin-lighthouse" }
  ingress {
    description = "Nebula"
    from_port   = 4242
    to_port     = 4242
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "VPC DNS UDP"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["10.202.0.2/32"]
  }
  egress {
    description = "VPC DNS TCP"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["10.202.0.2/32"]
  }
  egress {
    description = "HTTPS for SSM and Secrets Manager"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Nebula UDP replies and operation"
    from_port   = 4242
    to_port     = 4242
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "tarkin" {
  domain = "vpc"
  tags   = { Name = "tarkin" }
}
