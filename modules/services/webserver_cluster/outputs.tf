output "app_url" {
  description = "The URL to connect to the application."
  value       = "http://${aws_lb.this.dns_name}"
}

output "alb_sg_id" {
  description = "The ID of the SG attached to the LB."
  value       = aws_security_group.this_lb.id
}

output "lt_sg_id" {
  description = "The ID of the SG attached to the LT."
  value       = aws_security_group.this_lt.id
}

