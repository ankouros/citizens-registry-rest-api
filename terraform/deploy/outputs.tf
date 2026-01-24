# Δημόσιο σημείο πρόσβασης της εφαρμογής μέσω ALB.
output "load_balancer_dns" {
  description = "Δημόσιο DNS του load balancer για τη REST υπηρεσία"
  value       = aws_lb.rest_lb.dns_name
}

# Ιδιωτικές IPs των REST στιγμιοτύπων (ενημερωτικός χαρακτήρας).
output "rest_private_ips" {
  description = "Ιδιωτικές διευθύνσεις IP των REST instances"
  value       = aws_instance.rest[*].private_ip
}

# Ιδιωτική IP του στιγμιοτύπου της βάσης.
output "db_private_ip" {
  description = "Ιδιωτική διεύθυνση IP του DB instance"
  value       = aws_instance.db.private_ip
}
