variable "enabled" {
  type        = bool
  description = "Set to false to prevent the module from creating any resources"
  default     = true
}
variable "description" {
  type        = list(string)
  description = "Description"
}
variable "alias_name" {
  type        = list(string)
  description = "Alias Name"
}
variable "deletion_window_in_days" {
  type        = list(number)
  description = "Duration in days after which the key is permenently deleted"
}
variable "enable_key_rotation" {
  type        = list(bool)
  description = "Whether or not automated key rotation is enabled"
}
variable "policy" {
  description = "A valid KMS policy JSON document."
  default     = ""
}
variable "tags" {
  type    = map(string)
  default = {}
}