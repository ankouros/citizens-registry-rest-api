// Επιστρέφει το AMI που θα τροφοδοτήσει τη φάση deploy.
output "rest_ami_id" {
  description = "AMI ID που παράγεται στη φάση prepare για χρήση στη φάση deploy"
  value       = aws_ami_from_instance.rest_ami.id
}
