output "iam_role_name" {
  value       = join("", aws_iam_role.default.*.name)
  description = "The name of the IAM role created"
}

output "id" {
  value       = join("", aws_iam_role.default.*.unique_id)
  description = "The stable and unique string identifying the role"
}

output "iam_role_arn" {
  value       = join("", aws_iam_role.default.*.arn)
  description = "The Amazon Resource Name (ARN) specifying the role"
}

output "policy" {
  value       = module.aggregated_policy.result_document
  description = "Role policy document in json format. Outputs always, independent of `enabled` variable"
}

output "iam_instance_profile_name" {
  value       = join("", aws_iam_instance_profile.this.*.name)
  description = "The name of the IAM instance profile created"
}

output "iam_instance_profile_arn" {
  value       = join("", aws_iam_instance_profile.this.*.arn)
  description = "The name of the IAM instance profile created"
}
