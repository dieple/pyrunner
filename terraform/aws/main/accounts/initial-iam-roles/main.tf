locals {
  iam_data = {
    default = {
      role_name_admin                        = "administrators"
      role_name_dev                          = "developers"
      role_name_ops                          = "operations"
      role_name_cw                           = "cloudwatch"
      aws_iam_root_account_id                = [local.org_accounts["master"], local.org_accounts["sre"]]
      override_read_only_policy              = false
      override_read_only_policy_arn          = ""
      override_administrator_policy          = false
      override_administrator_policy_arn      = ""
      override_administrator_role_policy     = false
      override_administrator_role_policy_arn = ""
      override_developer_role_policy         = false
      override_developer_role_policy_arn     = ""
      developers_full_access                 = false
      override_operations_role_policy        = false
      override_operations_role_policy_arn    = ""
      operations_full_access                 = false
      aws_monitoring_account_ids             = [local.org_accounts["master"], local.org_accounts["sre"]]
    },
  }
}

module "iam_role_member_account" {
  source                                 = "../../../modules/accounts/initial-iam-roles"
  aws_iam_root_account_id                = lookup(local.iam_data["default"], "aws_iam_root_account_id")
  role_name_dev                          = lookup(local.iam_data["default"], "role_name_dev")
  role_name_admin                        = lookup(local.iam_data["default"], "role_name_admin")
  role_name_ops                          = lookup(local.iam_data["default"], "role_name_ops")
  role_name_cw                           = lookup(local.iam_data["default"], "role_name_cw")
  developers_full_access                 = lookup(local.iam_data["default"], "developers_full_access")
  operations_full_access                 = lookup(local.iam_data["default"], "operations_full_access")
  override_administrator_policy          = lookup(local.iam_data["default"], "override_administrator_policy")
  override_administrator_policy_arn      = lookup(local.iam_data["default"], "override_administrator_policy_arn")
  override_read_only_policy_arn          = lookup(local.iam_data["default"], "override_read_only_policy_arn")
  override_administrator_role_policy_arn = lookup(local.iam_data["default"], "override_administrator_role_policy_arn")
  override_administrator_role_policy     = lookup(local.iam_data["default"], "override_administrator_role_policy")
  override_developer_role_policy         = lookup(local.iam_data["default"], "override_developer_role_policy")
  override_developer_role_policy_arn     = lookup(local.iam_data["default"], "override_developer_role_policy_arn")
  override_operations_role_policy        = lookup(local.iam_data["default"], "override_operations_role_policy")
  override_operations_role_policy_arn    = lookup(local.iam_data["default"], "override_operations_role_policy_arn")
  aws_monitoring_account_ids             = lookup(local.iam_data["default"], "aws_monitoring_account_ids")
}
