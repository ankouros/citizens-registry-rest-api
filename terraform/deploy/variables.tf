variable "aws_region" {
  description = "AWS region where the infrastructure is deployed"
  type        = string
  # Default kept for consistency with the lab scenario.
  default     = "eu-central-1"
}

variable "rest_ami" {
  description = "REST service AMI ID produced in prepare"
  type        = string
}

variable "db_ami" {
  description = "AMI ID for the database instance"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name for administrative access"
  type        = string
}
variable "db_port" {
  description = "Database port (e.g., 3306 for MySQL)"
  type        = number
  # MySQL default for the lab scenario.
  default     = 3306
}
