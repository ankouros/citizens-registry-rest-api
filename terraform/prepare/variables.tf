variable "aws_region" {
  description = "Περιοχή AWS όπου εκτελείται η φάση prepare"
  type        = string
  # Προεπιλογή συμβατή με το εκπαιδευτικό σενάριο.
  default     = "eu-central-1"
}

variable "base_ami" {
  description = "AMI βάσης Ubuntu πάνω στην οποία εγκαθίσταται μόνο το runtime"
  type        = string
}

variable "key_name" {
  description = "Όνομα EC2 key pair για διοικητική πρόσβαση στο προσωρινό instance"
  type        = string
}
