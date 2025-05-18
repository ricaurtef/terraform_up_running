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

variable "min_size" {
  description = "The minimum number of EC2 instances in the ASG."
  type        = number
}

variable "max_size" {
  description = "The maximum number of EC2 instances in the ASG."
  type        = number
}

variable "desired_capacity" {
  description = "The desired number of EC2 instances running at any time."
  type        = number
}

variable "asg_schedule_enabled" {
  description = "Enable ASG at a fixed schedule."
  type        = bool
  default     = false
}

variable "lb_sg_extra" {
  description = "Allow adding any additional rules to the LB SG."
  type = list(object({
    type        = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = optional(string, "Extra rule for LB SG.")
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.lb_sg_extra : can(regex("^(in|e)gress$", rule.type))
    ])
    error_message = "Each rule's type must be either 'ingress' or 'egress'."
  }

  validation {
    condition = alltrue([
      for rule in var.lb_sg_extra : rule.from_port >= 0 && rule.from_port <= 65535
    ])
    error_message = "Each rule's from_port must be between 0 and 65535."
  }

  validation {
    condition = alltrue([
      for rule in var.lb_sg_extra : rule.to_port >= 0 && rule.to_port <= 65535
    ])
    error_message = "Each rule's to_port must be between 0 and 65535."
  }

  validation {
    condition = alltrue([
      for rule in var.lb_sg_extra : rule.to_port >= rule.from_port
    ])
    error_message = "Each rule's to_port must be greater than or equal to from_port."
  }

  validation {
    condition = alltrue([
      for rule in var.lb_sg_extra :
      contains(["tcp", "udp", "icmp", "-1"], rule.protocol)
    ])
    error_message = <<-EOT
      Each rule's protocol must be:
      - tcp.
      - udp.
      - icmp.
      - -1 (for all).
    EOT
  }

  validation {
    condition = alltrue([
      for rule in var.lb_sg_extra : length(rule.cidr_blocks) > 0
    ])
    error_message = "Each rule must have at least one CIDR block."
  }
}

variable "custom_tags" {
  description = "Custom tags to set on the resources that make up the infrastructure."
  type        = map(string)
  default     = {}
}
