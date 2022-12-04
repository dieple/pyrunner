variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`)"
}

variable "log_group_names" {
  type        = list(string)
  description = "names of repositories to create"
  default     = []
}

variable "retention_in_days" {
  type = number
}