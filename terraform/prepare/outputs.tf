// Outputs the AMI used by the deploy phase.
output "rest_ami_id" {
  description = "AMI ID produced in prepare and consumed by deploy"
  value       = aws_ami_from_instance.rest_ami.id
}
