variable "db_name" {
  description = "The name of the database."
  type        = string
  default     = null
}

variable "db_main_username" {
  description = "The main database username."
  type        = string
  sensitive   = true
  default     = null

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
  default     = null

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

variable "backup_retention_period" {
  description = "Days to retain backups. Must be > 0 to enable replication."
  type        = number
  default     = null
}

variable "replicate_source_db" {
  description = "If specified, replicate the RDS database at the given ARN."
  type        = string
  default     = null

  validation {
    condition = (
      var.replicate_source_db == null ||
      can(regex(
        "^arn:(aws|aws-cn|aws-us-gov):rds:[a-z0-9-]+:[0-9]{12}:db:[a-zA-Z0-9-]+$",
        var.replicate_source_db
      ))
    )
    error_message = <<-EOT
    If set, replicate_source_db must be a valid RDS instance ARN, for example:
    arn:aws:rds:us-east-1:123456789012:db:my-db-instance
    EOT
  }
}
