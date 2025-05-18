output "state_bucket_name" {
  description = "The name of the bucket where the state is stored."
  value       = aws_s3_bucket.terraform_state.id
}
