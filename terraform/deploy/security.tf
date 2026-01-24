# --------------------
# ΟΜΑΔΑ ΑΣΦΑΛΕΙΑΣ: ΕΞΙΣΟΡΡΟΠΗΤΗΣ ΦΟΡΤΙΟΥ
# --------------------
resource "aws_security_group" "lb_sg" {
  name        = "lb-sg"
  description = "Security group για τον load balancer"
  vpc_id      = aws_vpc.main.id

  # Επιτρέπεται HTTP από το διαδίκτυο αποκλειστικά προς τον ALB.
  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Επιτρέπεται εξερχόμενη κίνηση ώστε ο ALB να επικοινωνεί με τα στιγμιότυπα-στόχους.
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
# ΟΜΑΔΑ ΑΣΦΑΛΕΙΑΣ: REST ΕΦΑΡΜΟΓΗ
# --------------------
resource "aws_security_group" "rest_sg" {
  name        = "rest-sg"
  description = "Security group για τα REST service instances"
  vpc_id      = aws_vpc.main.id

  # Επιτρέπεται εισερχόμενη κίνηση μόνο από τον ALB στη θύρα εφαρμογής.
  ingress {
    description     = "HTTP from Load Balancer"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  # Επιτρέπεται εξερχόμενη κίνηση για επικοινωνία με τη βάση και βασικές υπηρεσίες συστήματος.
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
# ΟΜΑΔΑ ΑΣΦΑΛΕΙΑΣ: ΒΑΣΗ ΔΕΔΟΜΕΝΩΝ
# --------------------
resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Security group για το instance της βάσης δεδομένων"
  vpc_id      = aws_vpc.main.id

  # Επιτρέπεται πρόσβαση στη βάση μόνο από τα REST στιγμιότυπα.
  ingress {
    description     = "DB access from REST service"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.rest_sg.id]
  }

  # Επιτρέπεται εξερχόμενη κίνηση για βασικές ενημερώσεις συστήματος.
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
