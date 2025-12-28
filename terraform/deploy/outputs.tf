
output "rest_instances" {
  value = aws_instance.rest[*].public_ip
}
