# infrastructure/terraform/main.tf
provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "finova_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "finova_subnet" {
  vpc_id            = aws_vpc.finova_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"
}

resource "aws_security_group" "finova_sg" {
  vpc_id = aws_vpc.finova_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "finova_ec2" {
  ami                    = "ami-0c55b159cbfafe1f0"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.finova_subnet.id
  security_groups        = [aws_security_group.finova_sg.name]
  associate_public_ip_address = true

  tags = {
    Name = "Finova-EC2"
  }
}
