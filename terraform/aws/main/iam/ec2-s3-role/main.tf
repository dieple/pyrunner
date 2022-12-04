locals {
  allowed_account_ids = [for name, id in local.org_accounts : id]
  acc_arn             = formatlist("arn:aws:ssm:%s:%s:parameter/%s/*", data.aws_region.current.name, local.allowed_account_ids, terraform.workspace)

  common_tags = {
    ClusterName = module.tag_label.id
  }

  iam_data = {
    sre = {
      create_ec2_iam_role = true
      create_ec2_profile  = true
      s3_kms_key_arn      = try(lookup(data.terraform_remote_state.kms.outputs.alias_map, "alias/s3-${terraform.workspace}", null))
      ssm_kms_arn         = try(lookup(data.terraform_remote_state.kms.outputs.alias_map, "alias/parameter-store-key-${terraform.workspace}", null))
      s3_list             = ["my-sync-data-bucket", "my-trade-data-bucket"]
    }

    dev = {
      create_ec2_iam_role = true
      create_ec2_profile  = true
      s3_kms_key_arn      = try(lookup(data.terraform_remote_state.kms.outputs.alias_map, "alias/s3-${terraform.workspace}", null))
      ssm_kms_arn         = try(lookup(data.terraform_remote_state.kms.outputs.alias_map, "alias/parameter-store-key-${terraform.workspace}", null))
      s3_list             = ["my-sync-data-bucket", "my-trade-data-bucket"]
    }

    stg = {
      create_ec2_iam_role = true
      create_ec2_profile  = true
      s3_kms_key_arn      = try(lookup(data.terraform_remote_state.kms.outputs.alias_map, "alias/s3-${terraform.workspace}", null))
      ssm_kms_arn         = try(lookup(data.terraform_remote_state.kms.outputs.alias_map, "alias/parameter-store-key-${terraform.workspace}", null))
      s3_list             = ["my-sync-data-bucket", "my-trade-data-bucket"]
    }

    qa = {
      create_ec2_iam_role = true
      create_ec2_profile  = true
      s3_kms_key_arn      = try(lookup(data.terraform_remote_state.kms.outputs.alias_map, "alias/s3-${terraform.workspace}", null))
      ssm_kms_arn         = try(lookup(data.terraform_remote_state.kms.outputs.alias_map, "alias/parameter-store-key-${terraform.workspace}", null))
      s3_list             = ["my-sync-data-bucket", "my-trade-data-bucket"]
    }

    prod = {
      create_ec2_iam_role = true
      create_ec2_profile  = true
      s3_kms_key_arn      = try(lookup(data.terraform_remote_state.kms.outputs.alias_map, "alias/s3-${terraform.workspace}", null))
      ssm_kms_arn         = try(lookup(data.terraform_remote_state.kms.outputs.alias_map, "alias/parameter-store-key-${terraform.workspace}", null))
      s3_list             = ["my-sync-data-bucket", "my-trade-data-bucket"]
    }

  }
}

data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

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
  attributes  = ["ec2-s3-role"]
}

module "ec2_iam_assumable_role" {
  source                 = "../../../modules/iam/role"
  enabled                = lookup(local.iam_data[terraform.workspace], "create_ec2_iam_role", false)
  create_ec2_profile     = lookup(local.iam_data[terraform.workspace], "create_ec2_profile", false)
  name                   = format("%s-%s", module.tag_label.id, "ec2")
  policy_description     = "Allow ec2 instances to access S3 bucket"
  role_description       = "IAM role with permissions to interact resources on S3 bucket"
  policy_documents       = [data.aws_iam_policy_document.ec2.json]
  additional_policy_arns = []
  tags                   = module.tag_label.tags

  principals = {
    Service = ["ec2.amazonaws.com"]
  }
}
