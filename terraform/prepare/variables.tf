variable "aws_region" {
  description = "AWS region used for the prepare phase"
  type        = string
  # Default aligned with the lab scenario.
  default     = "eu-central-1"
}

variable "base_ami" {
  description = "Base Ubuntu AMI used to install only the runtime"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name for admin access to the temporary instance"
  type        = string
}
