terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  # Region is configurable to keep AMI preparation reproducible.
  region = var.aws_region
}

# --------------------
# TEMPORARY PREP INSTANCE (BUILDER)
# --------------------
resource "aws_instance" "rest_tmp" {
  # Base Ubuntu AMI so only the runtime environment is installed.
  ami           = var.base_ami
  instance_type = "t2.micro"
  key_name      = var.key_name

  # Minimal bootstrap: install JRE so the AMI includes only runtime.
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
# STOP INSTANCE BEFORE IMAGE CREATION (CONSISTENT AMI)
# --------------------
resource "aws_ec2_instance_state" "stop_rest_tmp" {
  # Stopping ensures a consistent filesystem snapshot.
  instance_id = aws_instance.rest_tmp.id
  state       = "stopped"
}

# --------------------
# AMI CREATION FROM TEMPORARY INSTANCE
# --------------------
resource "aws_ami_from_instance" "rest_ami" {
  # AMI contains only the runtime environment, not business software.
  name               = "citizen-rest-ami"
  source_instance_id = aws_instance.rest_tmp.id

  depends_on = [
    aws_ec2_instance_state.stop_rest_tmp
  ]

  tags = {
    Name = "citizen-rest-ami"
  }
}
