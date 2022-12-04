variable "name" {
  description = "Desired name for the VPC Endpoint Service."
  type        = string
}

variable "gateway_load_balancer_arns" {
  description = "List of Amazon Resource Names of one or more Gateway Load Balancers for the endpoint service."
  type        = list(string)
  default     = null
}

variable "network_load_balancer_arns" {
  description = "List of Amazon Resource Names of one or more Network Load Balancers for the endpoint service."
  type        = list(string)
  default     = null
}

variable "private_domain" {
  description = "The private domain name for the service."
  type        = string
  default     = null
}

variable "acceptance_required" {
  description = "Whether or not VPC endpoint connection requests to the service must be accepted by the service owner."
  type        = bool
  default     = false
}

variable "allowed_principals" {
  description = "A list of the ARNs of principal to allow to discover a VPC endpoint service."
  type        = list(string)
  default     = []
}

variable "notification_configurations" {
  description = "A list of configurations of Endpoint Connection Notifications for VPC Endpoint events."
  type = list(object({
    sns_arn = string
    events  = list(string)
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}