output "asg_id" {
  value = aws_autoscaling_group.bastion_asg.id
}

output "asg_arn" {
  value = aws_autoscaling_group.bastion_asg.arn
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.bastion_asg.name
}

output "ssh_user" {
  value       = var.ssh_user
  description = "SSH user"
}

output "security_group_id" {
  value       = var.security_groups
  description = "Security group ID"
}

output "role" {
  value       = aws_iam_role.bastion_role.name
  description = "Name of AWS IAM Role associated with the instance"
}

output "role_arn" {
  value = aws_iam_role.bastion_role.arn
}


