locals {
  dev      = var.developers_full_access == false ? aws_iam_role.developers.name : ""
  ops      = var.operations_full_access == false ? aws_iam_role.operations.name : ""
  rd       = compact([local.dev, local.ops])
  dev_full = var.developers_full_access ? aws_iam_role.developers.name : ""
  adm      = compact([aws_iam_role.administrators.name, local.dev_full])
}


resource "aws_iam_role" "administrators" {
  name               = var.role_name_admin
  assume_role_policy = data.aws_iam_policy_document.administrators_assume_role_policy.json
}

resource "aws_iam_role" "developers" {
  name               = var.role_name_dev
  assume_role_policy = data.aws_iam_policy_document.developers_assume_role_policy.json
}

resource "aws_iam_role" "operations" {
  name               = var.role_name_ops
  assume_role_policy = data.aws_iam_policy_document.operations_assume_role_policy.json
}

resource "aws_iam_role" "cloudwatch_allow_read" {
  count              = length(var.aws_monitoring_account_ids) == 0 ? 0 : 1
  name               = var.role_name_cw
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_assume_role_policy[count.index].json
}

resource "aws_iam_policy" "base" {
  name   = "base"
  policy = data.aws_iam_policy_document.base.json
}

resource "aws_iam_policy_attachment" "base" {
  name = "base"
  roles = [
    aws_iam_role.administrators.name,
    aws_iam_role.developers.name,
    aws_iam_role.operations.name,
  ]
  policy_arn = aws_iam_policy.base.arn
}

// allow_all policy for administrators with override option for developers
resource "aws_iam_policy" "allow_all" {
  name   = "allow_all"
  policy = data.aws_iam_policy_document.allow_all.json
}

resource "aws_iam_policy_attachment" "administrator_access" {
  name  = format("%s-%s", var.role_name_admin, "access")
  roles = local.adm

  policy_arn = var.override_administrator_policy == false ? aws_iam_policy.allow_all.arn : var.override_administrator_policy_arn
  depends_on = [aws_iam_role.administrators]
}

// default AWS read only policy for developers and operations
resource "aws_iam_policy_attachment" "read_only_access" {
  name       = "read-only-access"
  roles      = local.rd
  policy_arn = var.override_read_only_policy == false ? "arn:aws:iam::aws:policy/ReadOnlyAccess" : var.override_read_only_policy_arn
}

// custom policy attachment for roles
resource "aws_iam_policy_attachment" "administrators" {
  count = var.override_administrator_role_policy == false ? 0 : 1
  name  = var.role_name_admin
  roles = [
    aws_iam_role.administrators.name,
  ]
  policy_arn = var.override_administrator_role_policy_arn
}

resource "aws_iam_policy_attachment" "developers" {
  count = var.override_developer_role_policy == false ? 0 : 1
  name  = var.role_name_dev
  //  policy_arn = var.override_developer_role_policy_arn
  policy_arn = aws_iam_policy.developer_override_policy.arn
  roles = [
    aws_iam_role.developers.name,
  ]
}

resource "aws_iam_policy_attachment" "operations" {
  count      = var.override_operations_role_policy == false ? 0 : 1
  name       = var.role_name_ops
  policy_arn = var.override_operations_role_policy_arn
  roles = [
    aws_iam_role.operations.name,
  ]
}

// allow access to all cloudwatch data
resource "aws_iam_policy" "cloudwatch_allow_read" {
  count  = length(var.aws_monitoring_account_ids) == 0 ? 0 : 1
  name   = "cloudwatch_allow_read"
  policy = data.aws_iam_policy_document.cloudwatch_allow_read[count.index].json
}

resource "aws_iam_policy_attachment" "cloudwatch_allow_read" {
  count      = length(var.aws_monitoring_account_ids) == 0 ? 0 : 1
  name       = format("%s-%s", var.role_name_admin, "access")
  policy_arn = aws_iam_policy.cloudwatch_allow_read[0].arn
  roles      = [aws_iam_role.cloudwatch_allow_read[0].name]
}
