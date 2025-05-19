output "region_1" {
  description = "The name of the first region."
  value       = data.aws_region.region_1.name
}

output "region_2" {
  description = "The name of the second region."
  value       = data.aws_region.region_2.name
}
