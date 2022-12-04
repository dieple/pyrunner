locals {
  common_tags = {
    Project = "My Amazing Project"
  }
}

data "aws_caller_identity" "current" {}

module "tag_label" {
  source      = "../../../modules/core/tagging"
  environment = terraform.workspace
  attributes  = ["kms"]
  tags        = local.common_tags
}

module "kms" {
  source                  = "../../../modules/management/kms"
  enabled                 = true
  alias_name              = lookup(local.kms_data[terraform.workspace], "alias_name", "")
  description             = lookup(local.kms_data[terraform.workspace], "description", "")
  deletion_window_in_days = lookup(local.kms_data[terraform.workspace], "deletion_window_in_days")
  enable_key_rotation     = lookup(local.kms_data[terraform.workspace], "enable_key_rotation", false)
  policy                  = lookup(local.kms_data[terraform.workspace], "policy", "")
  tags                    = module.tag_label.tags
}
