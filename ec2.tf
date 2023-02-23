resource "aws_security_group" "application" {
  name_prefix = "application"
  vpc_id      = aws_vpc.dev.id

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "example"
  }
}


resource "aws_instance" "testEc2" {
  ami           = "ami-0d3473eeaaa09830c"  # ID of the AMI to use
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnets.1.id
  vpc_security_group_ids = [aws_security_group.application.id]
  associate_public_ip_address = true
  
  ebs_block_device {
    device_name = "/dev/xvda"
    volume_type = "gp2"
    volume_size = 50
  }

  tags = {
    Name = "testAgain-instance"
  }
}
