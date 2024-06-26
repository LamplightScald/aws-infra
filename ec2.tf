resource "aws_security_group" "application" {
  name_prefix = "application"
  vpc_id      = aws_vpc.dev.id

  # ingress {
  #   from_port   = 0
  #   to_port     = 65535
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = ["${aws_security_group.loadBalancer.id}"]
  }


  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = ["${aws_security_group.database.id}"]
  }
  tags = {
    Name = "example"
  }
}

data "aws_ami" "latest_ami" {
  filter {
    name   = "name"
    values = ["csye6225_*"]
  }
  most_recent = true
}



# resource "aws_instance" "testEc2" {
#   ami                         = data.aws_ami.latest_ami.id
#   instance_type               = "t2.micro"
#   subnet_id                   = aws_subnet.public_subnets.1.id
#   vpc_security_group_ids      = [aws_security_group.application.id]
#   associate_public_ip_address = true
#   iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

#   user_data = <<EOF
#     #!/bin/bash
#     cd /home/ec2-user/webapp
#     echo "DB_HOST=${aws_db_instance.rds.address}" >> .env
#     echo "S3_BUCKET_NAME=${aws_s3_bucket.new_bucket.bucket}" >> .env
#     mkdir /product_image_uploads
#     sudo chmod 777 -R /home/ec2-user/webapp/product_image_uploads
#     sudo chmod 777 -R /var/log

#     sudo cp ./cloudwatch-config.json /opt/aws/amazon-cloudwatch-agent/etc/cloudwatch-config.json
#     sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/cloudwatch-config.json -s

#     NODE_ENV=.env node app.js

#     sudo systemctl daemon-reload
#     sudo systemctl restart setup_systemd
#     sudo systemctl status setup_systemd
#     sudo systemctl enable setup_systemd
#   EOF

#   # sudo kill $(sudo lsof -t -i :3000)
#   ebs_block_device {
#     device_name = "/dev/xvda"
#     volume_type = "gp2"
#     volume_size = 50
#   }
#   root_block_device {
#     volume_size = 20
#   }
#   tags = {
#     Name = "A5_ec2"
#   }
# }