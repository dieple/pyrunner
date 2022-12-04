output "security_group_id" {
  value = [data.terraform_remote_state.sg.outputs.security_group_id]
}

output "public_ip" {
  value       = module.ec2_instance.public_ip
  description = "Public IP of the instance (or EIP)"
}

output "private_ip" {
  value       = module.ec2_instance.private_ip
  description = "Private IP of the instance"
}