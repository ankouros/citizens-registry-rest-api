terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  # Region is configured via variable for consistency across prepare/deploy/destroy.
  region = var.aws_region
}

# --------------------
# DATABASE INSTANCE
# --------------------
resource "aws_instance" "db" {
  # DB base AMI keeps OS/runtime responsibilities separate from the app.
  ami                    = var.db_ami
  instance_type          = "t2.micro"
  key_name               = var.key_name
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  tags = {
    Name = "db-instance"
  }
}

# --------------------
# REST SERVICE INSTANCES
# --------------------
resource "aws_instance" "rest" {
  # Multiple instances for horizontal scaling behind the load balancer.
  count                  = 3
  ami                    = var.rest_ami
  instance_type          = "t2.micro"
  key_name               = var.key_name
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.rest_sg.id]

  tags = {
    Name = "rest-instance-${count.index}"
  }
}

# --------------------
# LOAD BALANCER (ALB)
# --------------------
resource "aws_lb" "rest_lb" {
  # Public ALB exposes the REST endpoint without direct instance access.
  name               = "rest-lb"
  internal           = false
  load_balancer_type = "application"
  subnets = [
    aws_subnet.public.id,
    aws_subnet.public_b.id
  ]
  security_groups = [aws_security_group.lb_sg.id]
}

resource "aws_lb_target_group" "rest_tg" {
  # Target group for the REST application port.
  name     = "rest-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_target_group_attachment" "rest_attach" {
  # Attach all REST instances to the target group.
  count            = 3
  target_group_arn = aws_lb_target_group.rest_tg.arn
  target_id        = aws_instance.rest[count.index].id
  port             = 8080
}

resource "aws_lb_listener" "http" {
  # HTTP listener on port 80 that forwards to the target group.
  load_balancer_arn = aws_lb.rest_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rest_tg.arn
  }
}
