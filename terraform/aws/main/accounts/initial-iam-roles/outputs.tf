output "administrators_role_arn" {
  value = module.iam_role_member_account.administrators_role_arn
}

output "developers_role_arn" {
  value = module.iam_role_member_account.developers_role_arn
}

output "operations_role_arn" {
  value = module.iam_role_member_account.operations_role_arn
}

output "cloudwatch_allow_read_role_arn" {
  value = module.iam_role_member_account.cloudwatch_allow_read_role_arn
}
