output "db_subnet_group_name" {
  value = module.rds_postgres.db_subnet_group_name
}

output "cluster_arn" {
  value = module.rds_postgres.cluster_arn
}

output "cluster_id" {
  value = module.rds_postgres.cluster_id
}

output "cluster_resource_id" {
  value = module.rds_postgres.cluster_resource_id
}

output "cluster_members" {
  value = module.rds_postgres.cluster_members
}

output "cluster_endpoint" {
  value = module.rds_postgres.cluster_endpoint
}

output "cluster_reader_endpoint" {
  value = module.rds_postgres.cluster_reader_endpoint
}

output "cluster_engine_version_actual" {
  value = module.rds_postgres.cluster_engine_version_actual
}

output "cluster_database_name" {
  value = module.rds_postgres.cluster_database_name
}

output "cluster_port" {
  value = module.rds_postgres.cluster_port
}

output "cluster_master_username" {
  value     = module.rds_postgres.cluster_master_username
  sensitive = true
}

output "cluster_hosted_zone_id" {
  value = module.rds_postgres.cluster_hosted_zone_id
}

# aws_rds_cluster_instances
output "cluster_instances" {
  value = module.rds_postgres.cluster_instances
}

# aws_rds_cluster_endpoint
output "additional_cluster_endpoints" {
  value = module.rds_postgres.additional_cluster_endpoints
}

# aws_rds_cluster_role_association
output "cluster_role_associations" {
  value = module.rds_postgres.cluster_role_associations
}

# Enhanced monitoring role
output "enhanced_monitoring_iam_role_name" {
  value = module.rds_postgres.enhanced_monitoring_iam_role_name
}

output "enhanced_monitoring_iam_role_arn" {
  value = module.rds_postgres.enhanced_monitoring_iam_role_arn
}

output "enhanced_monitoring_iam_role_unique_id" {
  value = module.rds_postgres.enhanced_monitoring_iam_role_unique_id
}

# aws_security_group
output "security_group_id" {
  value = module.rds_postgres.security_group_id
}

output "db_cluster_parameter_group_arn" {
  value = module.rds_postgres.db_cluster_parameter_group_arn
}

output "db_cluster_parameter_group_id" {
  value = module.rds_postgres.db_cluster_parameter_group_id
}

output "db_parameter_group_arn" {
  value = module.rds_postgres.db_parameter_group_arn
}

output "db_parameter_group_id" {
  value = module.rds_postgres.db_parameter_group_id
}
