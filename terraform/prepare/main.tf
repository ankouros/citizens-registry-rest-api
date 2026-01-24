terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  # Η περιοχή ορίζεται μέσω μεταβλητής ώστε η προετοιμασία AMI να είναι αναπαραγώγιμη.
  region = var.aws_region
}

# --------------------
# ΠΡΟΣΩΡΙΝΟ ΣΤΙΓΜΙΟΤΥΠΟ ΠΡΟΕΤΟΙΜΑΣΙΑΣ (Κατασκευαστής)
# --------------------
resource "aws_instance" "rest_tmp" {
  # Χρησιμοποιείται καθαρό Ubuntu AMI ώστε να εγκατασταθεί μόνο το περιβάλλον εκτέλεσης.
  ami           = var.base_ami
  instance_type = "t2.micro"
  key_name      = var.key_name

  # Ελάχιστο bootstrap: εγκατάσταση JRE ώστε η AMI να περιλαμβάνει μόνο περιβάλλον εκτέλεσης.
  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install -y openjdk-17-jre
  EOF

  tags = {
    Name = "rest-builder-instance"
  }
}

# --------------------
# ΔΙΑΚΟΠΗ ΣΤΙΓΜΙΟΤΥΠΟΥ ΠΡΙΝ ΤΗΝ ΕΙΚΟΝΟΛΗΨΙΑ (Συνεπής AMI)
# --------------------
resource "aws_ec2_instance_state" "stop_rest_tmp" {
  # Η διακοπή διασφαλίζει συνεπές στιγμιότυπο του συστήματος αρχείων.
  instance_id = aws_instance.rest_tmp.id
  state       = "stopped"
}

# --------------------
# ΔΗΜΙΟΥΡΓΙΑ AMI ΑΠΟ ΤΟ ΠΡΟΣΩΡΙΝΟ ΣΤΙΓΜΙΟΤΥΠΟ
# --------------------
resource "aws_ami_from_instance" "rest_ami" {
  # Η AMI περιλαμβάνει μόνο το περιβάλλον εκτέλεσης, όχι επιχειρησιακό λογισμικό.
  name               = "citizen-rest-ami"
  source_instance_id = aws_instance.rest_tmp.id

  depends_on = [
    aws_ec2_instance_state.stop_rest_tmp
  ]

  tags = {
    Name = "citizen-rest-ami"
  }
}
