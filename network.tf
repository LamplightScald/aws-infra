resource "aws_vpc" "dev" {
  cidr_block = var.cidr

  tags = {
    Name = var.name
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.dev.id

  tags = {
    Name = "main"
  }
}