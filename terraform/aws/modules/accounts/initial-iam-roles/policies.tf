locals {
  allowed_account_ids = flatten(concat(var.aws_iam_root_account_id))
  p_id                = formatlist("arn:aws:iam::%s:root", local.allowed_account_ids)

  cw_accounts = flatten(concat(var.aws_monitoring_account_ids))
  p_cw        = formatlist("arn:aws:iam::%s:root", local.cw_accounts)
}

data "aws_iam_policy_document" "administrators_assume_role_policy" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "AWS"
      identifiers = formatlist("arn:aws:iam::%s:root", var.aws_iam_root_account_id)

    }
  }
}

data "aws_iam_policy_document" "developers_assume_role_policy" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "AWS"
      identifiers = formatlist("arn:aws:iam::%s:root", var.aws_iam_root_account_id)

    }
  }
}

data "aws_iam_policy_document" "operations_assume_role_policy" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "AWS"
      identifiers = formatlist("arn:aws:iam::%s:root", var.aws_iam_root_account_id)

    }
  }
}

data "aws_iam_policy_document" "cloudwatch_assume_role_policy" {
  count = length(var.aws_monitoring_account_ids) == 0 ? 0 : 1

  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "AWS"
      identifiers = local.p_cw
    }
  }
}

data "aws_iam_policy_document" "base" {
  statement {
    effect = "Allow"

    actions = [
      "support:*",
      "aws-portal:View*",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "acm:RequestCertificate",
      "cloudwatch:DisableAlarmActions",
      "cloudwatch:EnableAlarmActions",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]

    resources = [
      "*",
    ]
  }

}

data "aws_iam_policy_document" "allow_all" {
  statement {
    effect = "Allow"

    actions = [
      "*",
    ]

    resources = [
      "*",
    ]
  }
}

// we must use a custom policy as the canned polices are used by the aws OrganizationAccountAccessRole which we need to use for now.
data "aws_iam_policy_document" "cloudwatch_allow_read" {
  count = length(var.aws_monitoring_account_ids) == 0 ? 0 : 1
  statement {
    effect = "Allow"

    actions = [
      "autoscaling:Describe*",
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "logs:Get*",
      "logs:Describe*",
      "sns:Get*",
      "sns:List*",
      "aws-portal:View*",
    ]

    resources = [
      "*",
    ]
  }

}

// allow iam developers to manage IAM users passwords and virtual MFA devices.
// This is all sent to cloudtrail and you can't alter policies!
data "aws_iam_policy_document" "developer_override_policy_document" {
  statement {
    actions = [
      "iam:List*",
      "iam:Get*",
      "iam:ChangePassword",
      "iam:UpdateLoginProfile",
      "iam:DeactivateMFADevice",
      "iam:DeleteVirtualMFADevice",
      "iam:ListGroups",
      "iam:ListPolicies",
      "iam:ListRoles",
      "iam:ListUsers",
      "ec2:DescribeInstances",
      "organizations:ListAccounts",
      "organizations:ListOrganizationalUnitsForParent",
      "organizations:ListPolicies",
      "organizations:ListRoots",
      "rds:DescribeDBInstances",
      "sns:ListTopics",
      "aws-portal:*Billing",
      "aws-portal:*Usage",
      "aws-portal:*PaymentMethods",
      "budgets:ViewBudget",
      "budgets:ModifyBudget",
      "ce:UpdatePreferences",
      "ce:CreateReport",
      "ce:UpdateReport",
      "ce:DeleteReport",
      "ce:CreateNotificationSubscription",
      "ce:UpdateNotificationSubscription",
      "ce:DeleteNotificationSubscription",
      "cur:DescribeReportDefinitions",
      "cur:PutReportDefinition",
      "cur:ModifyReportDefinition",
      "cur:DeleteReportDefinition",
      "purchase-orders:*PurchaseOrders",
      "pricing:Describe*",
      "pricing:Get*",
      "ses:VerifyEmailIdentity",
      "ses:SendEmail",
      "ses:SendTemplatedEmail",
      "ses:SendRawEmail",
      "ses:SendBulkTemplatedEmail"
    ]

    resources = [
      "*",
    ]
  }

  // allow developers to assume all developer roles in all accounts.
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    resources = [
      "arn:aws:iam::*:role/developers",
    ]
  }
}

resource "aws_iam_policy" "developer_override_policy" {
  name   = "developer_override_policy"
  policy = data.aws_iam_policy_document.developer_override_policy_document.json
}