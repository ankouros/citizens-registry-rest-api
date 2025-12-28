
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "rest_tmp" {
  ami           = var.base_ami
  instance_type = "t2.micro"
  key_name      = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install -y openjdk-17-jre
  EOF
}

resource "aws_ami_from_instance" "rest_ami" {
  name               = "citizen-rest-ami"
  source_instance_id = aws_instance.rest_tmp.id
}
