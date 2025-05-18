output "app_url" {
  description = "The URL to connect to the 'hello world' app."
  value       = "http://${aws_lb.hello_world_alb.dns_name}"
}
