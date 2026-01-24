variable "aws_region" {
  description = "Περιοχή AWS όπου θα αναπτυχθεί η υποδομή"
  type        = string
  # Διατηρείται προεπιλογή για συνέπεια με το εργαστηριακό σενάριο.
  default     = "eu-central-1"
}

variable "rest_ami" {
  description = "AMI ID της REST υπηρεσίας που παράγεται στη φάση prepare"
  type        = string
}

variable "db_ami" {
  description = "AMI ID για το instance της βάσης δεδομένων"
  type        = string
}

variable "key_name" {
  description = "Όνομα EC2 key pair για διοικητική πρόσβαση"
  type        = string
}
variable "db_port" {
  description = "Θύρα στην οποία ακούει η βάση (π.χ. 3306 για MySQL)"
  type        = number
  # Προεπιλογή MySQL για το σενάριο της άσκησης.
  default     = 3306
}
