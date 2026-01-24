# --------------------
# SECURITY GROUP: LOAD BALANCER
# --------------------
resource "aws_security_group" "lb_sg" {
  name        = "lb-sg"
  description = "Security group for load balancer"
  vpc_id      = aws_vpc.main.id

  # Allow HTTP from the Internet to the ALB only.
  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic so the ALB can reach target instances.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lb-security-group"
  }
}

# --------------------
# SECURITY GROUP: REST SERVICE
# --------------------
resource "aws_security_group" "rest_sg" {
  name        = "rest-sg"
  description = "Security group for REST service instances"
  vpc_id      = aws_vpc.main.id

  # Allow inbound traffic only from the ALB on the app port.
  ingress {
    description     = "HTTP from Load Balancer"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  # Allow outbound traffic for DB access and system services.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rest-security-group"
  }
}

# --------------------
# SECURITY GROUP: DATABASE
# --------------------
resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Security group for database instance"
  vpc_id      = aws_vpc.main.id

  # Allow DB access only from REST instances.
  ingress {
    description     = "DB access from REST service"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.rest_sg.id]
  }

  # Allow outbound traffic for basic system updates.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-security-group"
  }
}
