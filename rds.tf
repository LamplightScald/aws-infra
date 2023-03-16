resource "aws_security_group" "database" {
  name_prefix = "database"
  vpc_id      = aws_vpc.dev.id
  # ingress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  # ingress {
  #   from_port   = 0
  #   to_port     = 65535
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
}

resource "aws_security_group_rule" "mysql_ingress" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.database.id
  source_security_group_id = aws_security_group.application.id
}
resource "aws_db_subnet_group" "rds_subnet" {
  name = "rds_subnet"

  subnet_ids = [
    aws_subnet.private_subnets.0.id,
    aws_subnet.private_subnets.1.id,
    aws_subnet.private_subnets.2.id,
  ]
}

resource "aws_db_instance" "rds" {
  identifier             = "csye6225"
  engine                 = "mariadb"
  engine_version         = "10.6"
  instance_class         = "db.t3.micro"
  allocated_storage      = 10
  db_name                = "Demo"
  username               = "csye6225"
  password               = "20130548dj"
  publicly_accessible    = false
  skip_final_snapshot    = true
  parameter_group_name   = aws_db_parameter_group.db_parm.name
  vpc_security_group_ids = [aws_security_group.database.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet.name
  multi_az               = false
  tags = {
    Name = "my-rds-instance"
  }
}


# output "rds_endpoint" {
#   value = aws_db_instance.rds.address
# }

resource "aws_db_parameter_group" "db_parm" {
  name   = "db-param-group"
  family = "mariadb10.6"

  parameter {
    name  = "max_connections"
    value = "50"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
}