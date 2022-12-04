output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "database_subnets" {
  value = module.vpc.database_subnets
}

output "database_subnet_name" {
  value = module.vpc.database_subnet_name
}

output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc.nat_public_ips
}

#output "vpc_endpoint_ec2_id" {
#  description = "The ID of VPC endpoint for EC2"
#  value       = module.vpc_endpoints.endpoints["ec2"].id
#}
#
#output "vpc_endpoint_ec2_network_interface_ids" {
#  description = "One or more network interfaces for the VPC Endpoint for EC2."
#  value       = module.vpc_endpoints.endpoints["ec2"].network_interface_ids
#}
#
#output "vpc_endpoint_ec2_dns_entry" {
#  description = "The DNS entries for the VPC Endpoint for EC2."
#  value       = module.vpc_endpoints.endpoints["ec2"].dns_entry
#}

#output "vpc_endpoint_ssm_id" {
#  description = "The ID of VPC endpoint for SSM"
#  value       = module.vpc_endpoints.endpoints["ssm"].id
#}

#output "vpc_endpoint_ssm_network_interface_ids" {
#  description = "One or more network interfaces for the VPC Endpoint for SSM."
#  value       = module.vpc_endpoints.endpoints["ssm"].network_interface_ids
#}

#output "vpc_endpoint_ssm_dns_entry" {
#  description = "The DNS entries for the VPC Endpoint for SSM."
#  value       = module.vpc_endpoints.endpoints["ssm"].dns_entry
#}

#output "vpc_endpoint_lambda_id" {
#  description = "The ID of VPC endpoint for Lambda"
#  value       = module.vpc_endpoints.endpoints["lambda"].id
#}

#output "vpc_endpoint_lambda_network_interface_ids" {
#  description = "One or more network interfaces for the VPC Endpoint for Lambda."
#  value       = module.vpc_endpoints.endpoints["lambda"].network_interface_ids
#}

#output "vpc_endpoint_lambda_dns_entry" {
#  description = "The DNS entries for the VPC Endpoint for Lambda."
#  value       = module.vpc_endpoints.endpoints["lambda"].dns_entry
#}


output "cgw_ids" {
  description = "List of IDs of Customer Gateway"
  value       = module.vpc.cgw_ids
}

output "this_customer_gateway" {
  description = "Map of Customer Gateway attributes"
  value       = module.vpc.this_customer_gateway
}

output "azs" {
  value = module.vpc.azs
}
