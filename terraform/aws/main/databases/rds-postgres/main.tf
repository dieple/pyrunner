locals {
  custom_tags = {
    ProjectName = "Laser Digital Asset Trading"
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket         = lookup(var.envs[terraform.workspace], "bucket")
    key            = format("env:/%s/%s/%s", terraform.workspace, "vpc", "terraform.tfstate")
    region         = lookup(var.envs[terraform.workspace], "bucket_region")
    dynamodb_table = lookup(var.envs[terraform.workspace], "dynamodb")
  }
}

data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket         = lookup(var.envs[terraform.workspace], "bucket")
    key            = format("env:/%s/%s/%s", terraform.workspace, "rds-monitoring-role", "terraform.tfstate")
    region         = lookup(var.envs[terraform.workspace], "bucket_region")
    dynamodb_table = lookup(var.envs[terraform.workspace], "dynamodb")
  }
}

data "terraform_remote_state" "kms" {
  backend = "s3"

  config = {
    bucket         = lookup(var.envs[terraform.workspace], "bucket")
    key            = format("env:/%s/%s/%s", terraform.workspace, "kms", "terraform.tfstate")
    region         = lookup(var.envs[terraform.workspace], "bucket_region")
    dynamodb_table = lookup(var.envs[terraform.workspace], "dynamodb")
  }
}

module "tag_label" {
  source      = "../../../modules/core/tagging"
  environment = terraform.workspace
  attributes  = ["rds-postgres"]
  tags        = local.custom_tags
}

module "dbname_label" {
  source      = "../../../modules/core/tagging"
  environment = terraform.workspace
  attributes  = ["postgres"]
  delimiter   = "_" # Error: "DatabaseName must begin with a letter and contain only alphanumeric characters"
  tags        = local.custom_tags
}


resource "random_password" "master" {
  length = 10
}

module "rds_postgres" {
  source                                 = "../../../modules/databases/rds-postgres"
  name                                   = lookup(local.rds_data[terraform.workspace], "name")
  database_name                          = lookup(local.rds_data[terraform.workspace], "database_name")
  cluster_identifier                     = lookup(local.rds_data[terraform.workspace], "cluster_identifier")
  engine                                 = lookup(local.rds_data[terraform.workspace], "engine")
  engine_version                         = lookup(local.rds_data[terraform.workspace], "engine_version")
  vpc_id                                 = lookup(local.rds_data[terraform.workspace], "vpc_id")
  create_db_subnet_group                 = lookup(local.rds_data[terraform.workspace], "create_db_subnet_group")
  create_security_group                  = lookup(local.rds_data[terraform.workspace], "create_security_group")
  allowed_cidr_blocks                    = lookup(local.rds_data[terraform.workspace], "allowed_cidr_blocks")
  iam_database_authentication_enabled    = lookup(local.rds_data[terraform.workspace], "iam_database_authentication_enabled")
  master_password                        = lookup(local.rds_data[terraform.workspace], "master_password")
  master_username                        = lookup(local.rds_data[terraform.workspace], "master_username")
  create_random_password                 = lookup(local.rds_data[terraform.workspace], "create_random_password")
  apply_immediately                      = lookup(local.rds_data[terraform.workspace], "apply_immediately")
  skip_final_snapshot                    = lookup(local.rds_data[terraform.workspace], "skip_final_snapshot")
  enabled_cloudwatch_logs_exports        = lookup(local.rds_data[terraform.workspace], "enabled_cloudwatch_logs_exports")
  instances                              = lookup(local.rds_data[terraform.workspace], "instances")
  create_db_cluster_parameter_group      = lookup(local.rds_data[terraform.workspace], "create_db_cluster_parameter_group")
  db_cluster_parameter_group_name        = lookup(local.rds_data[terraform.workspace], "db_cluster_parameter_group_name")
  db_cluster_parameter_group_family      = lookup(local.rds_data[terraform.workspace], "db_cluster_parameter_group_family")
  db_cluster_parameter_group_description = lookup(local.rds_data[terraform.workspace], "db_cluster_parameter_group_description")
  create_db_parameter_group              = lookup(local.rds_data[terraform.workspace], "create_db_parameter_group")
  db_parameter_group_name                = lookup(local.rds_data[terraform.workspace], "db_parameter_group_name")
  db_parameter_group_family              = lookup(local.rds_data[terraform.workspace], "db_parameter_group_family")
  db_parameter_group_description         = lookup(local.rds_data[terraform.workspace], "db_parameter_group_description")
  db_cluster_parameter_group_parameters  = lookup(local.rds_data[terraform.workspace], "db_cluster_parameter_group_parameters")
  db_parameter_group_parameters          = lookup(local.rds_data[terraform.workspace], "db_parameter_group_parameters")
  kms_key_id                             = lookup(local.rds_data[terraform.workspace], "kms_key_id")
  monitoring_interval                    = lookup(local.rds_data[terraform.workspace], "monitoring_interval")
  create_monitoring_role                 = lookup(local.rds_data[terraform.workspace], "create_monitoring_role")
  subnets                                = lookup(local.rds_data[terraform.workspace], "subnets")
  autoscaling_enabled                    = lookup(local.rds_data[terraform.workspace], "autoscaling_enabled")
  autoscaling_min_capacity               = lookup(local.rds_data[terraform.workspace], "autoscaling_min_capacity")
  autoscaling_max_capacity               = lookup(local.rds_data[terraform.workspace], "autoscaling_max_capacity")
  preferred_backup_window                = lookup(local.rds_data[terraform.workspace], "preferred_backup_window")
  tags                                   = module.tag_label.tags
}
