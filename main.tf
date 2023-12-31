provider "aws" {
  access_key = "AKIAUUA73YQNXRPKKDNX"
  secret_key = "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"
  region = "eu-west-2"
}


# Create a VPC
resource "aws_vpc" "app_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "app-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "vpc_igw"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone = "eu-west-2a"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_rt"
  }
}

resource "aws_route_table_association" "public_rt_asso" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}



resource "aws_instance" "web_jenkins" {
  ami           = "ami-0eb260c4d5475b901" 
  instance_type = var.instance_type
  key_name = var.instance_key
  subnet_id              = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.sg.id]
  user_data = file("${path.module}/jenkins.sh")
  

  tags = {
    Name = "Jenkins"
  }
}

resource "aws_instance" "web_Wildfly" {
  ami           = "ami-0eb260c4d5475b901" 
  instance_type = var.instance_type
  key_name = var.instance_key
  subnet_id              = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.sg.id]
  user_data = file("${path.module}/wildfly.sh")

  tags = {
    Name = "Wildfly"
  }
}
