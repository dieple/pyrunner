locals {
  retention_in_days = 90

  log_group_names = {
    default = [
      "/elasticsearch/${terraform.workspace}/index_slow_logs",
      "/elasticsearch/${terraform.workspace}/search_slow_logs",
      "/elasticsearch/${terraform.workspace}/es_application_logs",
      "/elasticsearch/${terraform.workspace}/audit_logs",
    ]
  }

}

module "tag_label" {
  source      = "../../../modules/core/tagging"
  environment = terraform.workspace
  attributes  = ["log-group"]
}

module "log_group" {
  source            = "../../../modules/monitoring/cloudwatch-log-groups"
  retention_in_days = local.retention_in_days
  log_group_names   = local.log_group_names["default"]
  tags              = module.tag_label.tags
}
