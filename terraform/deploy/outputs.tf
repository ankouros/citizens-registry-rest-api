# Public application entrypoint via the ALB.
output "load_balancer_dns" {
  description = "Public DNS of the load balancer for the REST service"
  value       = aws_lb.rest_lb.dns_name
}

# Private IPs of the REST instances (informational).
output "rest_private_ips" {
  description = "Private IP addresses of the REST instances"
  value       = aws_instance.rest[*].private_ip
}

# Private IP of the database instance.
output "db_private_ip" {
  description = "Private IP address of the DB instance"
  value       = aws_instance.db.private_ip
}
