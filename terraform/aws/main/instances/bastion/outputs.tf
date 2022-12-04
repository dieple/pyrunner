output "asg_id" {
  value = module.bastion.asg_id
}

output "asg_arn" {
  value = module.bastion.asg_arn
}

output "autoscaling_group_name" {
  value = module.bastion.autoscaling_group_name
}

output "ssh_user" {
  value = module.bastion.ssh_user
}

output "security_group_id" {
  value = module.bastion.security_group_id
}

output "role" {
  value = module.bastion.role
}

output "role_arn" {
  value = module.bastion.role_arn
}

output "public_ip" {
  value       = aws_eip.bastion.public_ip
  description = "Public IP of the instance (or EIP)"
}

output "private_ip" {
  value       = aws_eip.bastion.private_ip
  description = "Private IP of the instance"
}