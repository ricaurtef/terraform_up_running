variable "server_port" {
  description = "The port the server will use for HTTP requests."
  type        = number
}

variable "ssm_port" {
  description = "The port the ssm agent uses to reach SSM endpoints."
  type        = number
  default     = 443
}
