# --------------------
# VPC (Εικονικό Ιδιωτικό Δίκτυο)
# --------------------
resource "aws_vpc" "main" {
  # Ενιαίο VPC για σαφή οριοθέτηση του εργαστηριακού περιβάλλοντος.
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "citizens-registry-vpc"
  }
}

# --------------------
# ΠΥΛΗ ΠΡΟΣ ΤΟ ΔΙΑΔΙΚΤΥΟ (Internet Gateway)
# --------------------
resource "aws_internet_gateway" "igw" {
  # Απαραίτητο για δημόσια πρόσβαση στον εξισορροπητή φορτίου.
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "citizens-registry-igw"
  }
}

# --------------------
# ΔΗΜΟΣΙΟ ΥΠΟΔΙΚΤΥΟ (Εξισορροπητής Φορτίου)
# --------------------
resource "aws_subnet" "public" {
  # Δημόσιο υποδίκτυο για τον ALB ώστε να δέχεται εισερχόμενη κίνηση.
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name = "public-subnet"
  }
}

# --------------------
# ΙΔΙΩΤΙΚΟ ΥΠΟΔΙΚΤΥΟ (REST + DB)
# --------------------
resource "aws_subnet" "private" {
  # Ιδιωτικό υποδίκτυο για REST και DB ώστε να μην εκτίθενται δημόσια.
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "private-subnet"
  }
}

# --------------------
# ΠΙΝΑΚΑΣ ΔΗΜΟΣΙΩΝ ΔΡΟΜΟΛΟΓΗΣΕΩΝ
# --------------------
resource "aws_route_table" "public_rt" {
  # Πίνακας δρομολόγησης που επιτρέπει έξοδο στο διαδίκτυο μέσω IGW.
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_assoc" {
  # Σύνδεση του δημόσιου υποδικτύου με τον δημόσιο πίνακα δρομολόγησης.
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

# --------------------
# ΠΙΝΑΚΑΣ ΙΔΙΩΤΙΚΩΝ ΔΡΟΜΟΛΟΓΗΣΕΩΝ
# --------------------
resource "aws_route_table" "private_rt" {
  # Ιδιωτική δρομολόγηση χωρίς 0.0.0.0/0, ώστε να αποφεύγεται άμεση έκθεση.
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "private_assoc" {
  # Σύνδεση του ιδιωτικού υποδικτύου με τον ιδιωτικό πίνακα δρομολόγησης.
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_rt.id
}

# --------------------
# ΔΕΥΤΕΡΟ ΔΗΜΟΣΙΟ ΥΠΟΔΙΚΤΥΟ (απαίτηση ALB)
# --------------------
resource "aws_subnet" "public_b" {
  # Δεύτερο δημόσιο υποδίκτυο σε άλλη ζώνη διαθεσιμότητας (AZ), απαίτηση του ALB.
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}b"

  tags = {
    Name = "public-subnet-b"
  }
}

resource "aws_route_table_association" "public_assoc_b" {
  # Σύνδεση του δεύτερου δημόσιου υποδικτύου στον ίδιο δημόσιο πίνακα δρομολόγησης.
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}
