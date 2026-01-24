terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  # Η περιοχή ανάπτυξης καθορίζεται από μεταβλητή για συνέπεια με τις φάσεις prepare/deploy/destroy.
  region = var.aws_region
}

# --------------------
# ΣΤΙΓΜΙΟΤΥΠΟ ΒΑΣΗΣ ΔΕΔΟΜΕΝΩΝ
# --------------------
resource "aws_instance" "db" {
  # Το AMI βάσης DB διατηρεί την ευθύνη του λειτουργικού περιβάλλοντος, όχι της εφαρμογής.
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
# ΣΤΙΓΜΙΟΤΥΠΑ REST ΥΠΗΡΕΣΙΑΣ
# --------------------
resource "aws_instance" "rest" {
  # Πολλαπλά στιγμιότυπα για οριζόντια κλιμάκωση μέσω εξισορροπητή φορτίου.
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
# ΕΞΙΣΟΡΡΟΠΗΤΗΣ ΦΟΡΤΙΟΥ (ALB)
# --------------------
resource "aws_lb" "rest_lb" {
  # Δημόσιος ALB για έκθεση του REST τελικού σημείου χωρίς άμεση πρόσβαση στα στιγμιότυπα.
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
  # Ομάδα στόχων που αντιστοιχεί στη θύρα εφαρμογής των REST στιγμιοτύπων.
  name     = "rest-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_target_group_attachment" "rest_attach" {
  # Σύνδεση όλων των REST στιγμιοτύπων στην ομάδα στόχων.
  count            = 3
  target_group_arn = aws_lb_target_group.rest_tg.arn
  target_id        = aws_instance.rest[count.index].id
  port             = 8080
}

resource "aws_lb_listener" "http" {
  # Ακροατής HTTP στη θύρα 80 που προωθεί προς την ομάδα στόχων.
  load_balancer_arn = aws_lb.rest_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rest_tg.arn
  }
}
