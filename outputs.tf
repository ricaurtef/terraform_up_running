output "lb_dns_name" {
  description = "Load balancer DN."
  value       = aws_lb.example_lb.dns_name
}
