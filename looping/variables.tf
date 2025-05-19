variable "matrix_protagonists" {
  description = "The Matrix leading characters."
  type        = list(string)
  default     = ["neo", "trinity", "morpheus"]
}

variable "matrix_protagonists_role" {
  description = "The role of 'The Matrix' leading characters."
  type        = map(string)
  default = {
    neo      = "hero",
    trinity  = "hero's love interest",
    morpheus = "hero's mentor",
  }
}
