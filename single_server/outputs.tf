output "app_url" {
  description = "The URL to connect to the 'hello world' app."
  value       = "http://${aws_instance.example.public_dns}:8080"
}
