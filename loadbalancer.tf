resource "aws_security_group" "loadBalancer" {
  name_prefix = "load_balancer_sg_"
  vpc_id      = aws_vpc.dev.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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


resource "aws_launch_configuration" "autoLauchConfig" {
  name_prefix     = "autoLauchConfig-"
  image_id        = data.aws_ami.latest_ami.id
  associate_public_ip_address = true
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.application.id]
    iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  user_data       = <<EOF
    #!/bin/bash
    cd /home/ec2-user/webapp
    echo "DB_HOST=${aws_db_instance.rds.address}" >> .env
    echo "S3_BUCKET_NAME=${aws_s3_bucket.new_bucket.bucket}" >> .env
    mkdir /product_image_uploads
    sudo chmod 777 -R /home/ec2-user/webapp/product_image_uploads
    sudo chmod 777 -R /var/log

    sudo cp ./cloudwatch-config.json /opt/aws/amazon-cloudwatch-agent/etc/cloudwatch-config.json
    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/cloudwatch-config.json -s

    NODE_ENV=.env node app.js

    sudo systemctl daemon-reload
    sudo systemctl restart setup_systemd
    sudo systemctl status setup_systemd
    sudo systemctl enable setup_systemd
  EOF

  #   block_device_mappings {
  #   device_name = "/dev/xvda"
  #   ebs {
  #     volume_size = 20
  #     volume_type = "gp2"
  #     delete_on_termination = true
  #   }
  # }
  root_block_device {
    volume_size = 20
  }
}

resource "aws_autoscaling_group" "autoscalingGroup" {
  name                 = "loadbalancer-asg"
  vpc_zone_identifier  = [aws_subnet.public_subnets.1.id, aws_subnet.public_subnets.2.id]
  launch_configuration = aws_launch_configuration.autoLauchConfig.id
  min_size             = 1
  max_size             = 3
  default_cooldown     = 60
  desired_capacity     = 1
  health_check_type    = "EC2"
  target_group_arns    = [aws_lb_target_group.loadBalancer.arn]
  tag {
    key                 = "Application"
    value               = "WebApp"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scaleUp" {
  name                   = "scaleUp-policy"
  policy_type            = "TargetTrackingScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.autoscalingGroup.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 5.0
  }
}
resource "aws_autoscaling_policy" "scaleDown" {
  name                   = "scaleDown-policy"
  policy_type            = "TargetTrackingScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.autoscalingGroup.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 3.0
  }
}

# Load Banlancer
resource "aws_lb_listener" "loadBalancer" {
  load_balancer_arn = aws_lb.loadBalancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.loadBalancer.arn
    type             = "forward"
  }
}

# data "aws_autoscaling_groups" "asg" {
#   names = [aws_autoscaling_group.autoscalingGroup.name]
# }

resource "aws_lb_target_group" "loadBalancer" {
  name_prefix = "lb-tg-"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.dev.id

  health_check {
    path = "/healthz"
  }
}


# resource "aws_autoscaling_attachment" "asg_attachment" {
#   autoscaling_group_name = aws_autoscaling_group.autoscalingGroup.name
#   alb_target_group_arn   = aws_lb_target_group.loadBalancer.arn
# }

resource "aws_lb" "loadBalancer" {
  name               = "csye6225-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.loadBalancer.id]
  subnets            = [aws_subnet.public_subnets.1.id, aws_subnet.public_subnets.2.id]

  tags = {
    Application = "WebApp"

  }
}

