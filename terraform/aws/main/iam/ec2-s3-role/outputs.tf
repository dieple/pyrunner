output "iam_role_arn" {
  value = module.ec2_iam_assumable_role.iam_role_arn
}

output "iam_role_name" {
  value = module.ec2_iam_assumable_role.iam_role_name
}

output "iam_instance_profile_arn" {
  value = module.ec2_iam_assumable_role.iam_instance_profile_arn
}

output "iam_instance_profile_name" {
  value = module.ec2_iam_assumable_role.iam_instance_profile_name
}