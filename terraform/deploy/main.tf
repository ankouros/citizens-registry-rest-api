
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

resource "aws_instance" "db" {
  ami           = var.db_ami
  instance_type = "t2.micro"
  key_name      = var.key_name
}

resource "aws_instance" "rest" {
  count         = 3
  ami           = var.rest_ami
  instance_type = "t2.micro"
  key_name      = var.key_name
}
