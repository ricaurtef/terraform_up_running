variable "application_name" {
  description = "App name will be used to identify resources."
  type        = string
  default     = "hello-world"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z-]+$", var.application_name))
    error_message = <<-EOT
    The name must start with a letter and may contain letters or hyphens,
    but not start with a hyphen.
    EOT
  }
}

variable "instance_type" {
  description = <<-EOT
  The EC2 instance type to use for the nodes in the Auto Scaling Group.
  Determines the vCPU, memory, and networking capacity of each instance launched by the launch template.
  EOT
  type        = string

  validation {
    condition = contains([
      "t2.micro",
    ], var.instance_type)
    error_message = "Invalid instance type. Please provide a valid AWS EC2 instance type."
  }
}

variable "server_port" {
  description = "The port servers will use for HTTP requests."
  type        = number

  validation {
    condition     = var.server_port >= 1024 && var.server_port <= 65535
    error_message = "Invalid server port (1024-65535)."
  }
}
