variable "aws_iam_root_account_id" {
  type        = list(string)
  description = "account id of the root IAM account"
}

// read_only policy override
variable "override_read_only_policy" {
  type        = bool
  description = "override the policy"
  default     = false
}

variable "override_read_only_policy_arn" {
  type        = string
  description = "name of the policy to override"
  default     = ""
}

// administrator policies override
variable "override_administrator_policy" {
  type        = bool
  description = "override the policy"
  default     = false
}

variable "override_administrator_policy_arn" {
  type        = string
  description = "name of the policy to override"
  default     = ""
}

// administrator role policies
variable "override_administrator_role_policy" {
  type        = bool
  description = "override the policy"
  default     = false
}

variable "override_administrator_role_policy_arn" {
  type        = string
  description = "name of the policy to override"
  default     = ""
}

// developer role policies
variable "override_developer_role_policy" {
  type        = bool
  description = "override the policy"
  default     = false
}

variable "override_developer_role_policy_arn" {
  type        = string
  description = "name of the policy to override"
  default     = ""
}

variable "developers_full_access" {
  type        = bool
  description = "give the developers group full access to this account"
  default     = false
}

// operations role policies
variable "override_operations_role_policy" {
  type        = bool
  description = "name of the policy to override"
  default     = false
}

variable "override_operations_role_policy_arn" {
  type        = string
  description = "name of the policy to override"
  default     = ""
}

variable "operations_full_access" {
  type        = bool
  description = "give the developers group full access to this account"
  default     = false
}

// CloudWatch read only role policies
variable "aws_monitoring_account_ids" {
  type        = list(string)
  description = "account id allowed to assume the CloudWatch role and monitor it."
}

variable "role_name_cw" {}
variable "role_name_dev" {}
variable "role_name_admin" {}
variable "role_name_ops" {}
