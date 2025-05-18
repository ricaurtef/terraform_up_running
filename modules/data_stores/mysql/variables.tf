locals {
  has_min_length = length(var.db_main_password) >= 10
  has_uppercase  = length(regexall("[A-Z]", var.db_main_password)) > 0
  has_lowercase  = length(regexall("[a-z]", var.db_main_password)) > 0
  has_number     = length(regexall("[0-9]", var.db_main_password)) > 0
  has_special    = length(regexall("[^a-zA-Z0-9]", var.db_main_password)) > 0
}

variable "db_main_username" {
  description = "The main database username."
  type        = string
  sensitive   = true

  validation {
    condition = (
      can(regex("^[a-zA-Z][\\w.-]+$", var.db_main_username))
      && length(var.db_main_username) <= 32
    )
    error_message = <<-EOF
    The username must start with a letter, be no more than 32 characters, and only contain letters,
    digits, underscores (_), hyphens (-), and periods (.).
    EOF
  }
}

variable "db_main_password" {
  description = "The main database password."
  type        = string
  sensitive   = true

  validation {
    condition = (
      length(var.db_main_password) >= 10
      && length(regexall("[A-Z]", var.db_main_password)) > 0
      && length(regexall("[a-z]", var.db_main_password)) > 0
      && length(regexall("[0-9]", var.db_main_password)) > 0
      && length(regexall("[^a-zA-Z0-9]", var.db_main_password)) > 0
    )
    error_message = <<-EOT
    Password must be at least 10 characters long and include:
    - At least one uppercase letter.
    - At least one lowercase letter.
    - At least one digit.
    - At least one special character.
    EOT
  }
}

