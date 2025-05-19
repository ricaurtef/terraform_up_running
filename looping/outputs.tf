# Looping over a list.
output "matrix_upper" {
  description = "Uppercase character names."
  value = [
    for name in var.matrix_protagonists : upper(name)
  ]
}

output "shortest_matrix_upper" {
  description = "Shortest uppercase character names."
  value = [
    for name in var.matrix_protagonists : upper(name) if length(name) < 5
  ]
}

# Looping over a map.
output "matrix_roles" {
  description = "The role of each main character."
  value = [
    for name, role in var.matrix_protagonists_role : "${title(name)} is the ${role}."
  ]
}

output "matrix_roles_map" {
  description = "The role of each main character as a map."
  value = {
    for name, role in var.matrix_protagonists_role :
    title(name) => "${replace(role, substr(role, 0, 1), upper(substr(role, 0, 1)))}."
  }
}

# Looping with 'String Directive'.
locals {
  matrix_string_2 = trimsuffix(
    "%{for name in var.matrix_protagonists}${title(name)}, %{endfor}",
    ", "
  )
  matrix_string_3 = [
    for name in var.matrix_protagonists : title(name)
  ]
}

output "matrix_string_1" {
  description = "Titlecase character names as a string."
  value = replace(
    "%{for name in var.matrix_protagonists}${title(name)}, %{endfor}",
    "/, $/",
    "."
  )
}

output "matrix_string_2" {
  description = "Titlecase character names as a string."
  value       = "${local.matrix_string_2}."
}

## This approach doesn't use the string directive "for".
output "matrix_string_3" {
  description = "Titlecase character names as a string."
  value       = "${join(", ", local.matrix_string_3)}."
}
