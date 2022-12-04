locals {
  bucket_name = lookup(local.s3_data[terraform.workspace], "bucket", null) == "" ? module.tag_label.id : lookup(local.s3_data[terraform.workspace], "bucket", null)
}

module "tag_label" {
  source      = "../../../modules/core/tagging"
  environment = terraform.workspace
  attributes  = ["ld-sync-data"]
  tags        = {}
}

module "s3_bucket" {
  source                               = "terraform-aws-modules/s3-bucket/aws"
  version                              = "2.15.0"
  bucket                               = local.bucket_name
  acl                                  = lookup(local.s3_data[terraform.workspace], "acl", null)
  force_destroy                        = lookup(local.s3_data[terraform.workspace], "force_destroy", null)
  attach_policy                        = lookup(local.s3_data[terraform.workspace], "attach_policy", null)
  policy                               = data.aws_iam_policy_document.bucket_policy.json
  versioning                           = lookup(local.s3_data[terraform.workspace], "versioning", null)
  website                              = lookup(local.s3_data[terraform.workspace], "website", null)
  logging                              = lookup(local.s3_data[terraform.workspace], "logging", null)
  cors_rule                            = lookup(local.s3_data[terraform.workspace], "cors_rule", null)
  lifecycle_rule                       = lookup(local.s3_data[terraform.workspace], "lifecycle_rule", null)
  server_side_encryption_configuration = lookup(local.s3_data[terraform.workspace], "server_side_encryption_configuration", null)
  object_lock_configuration            = lookup(local.s3_data[terraform.workspace], "object_lock_configuration", null)
  block_public_acls                    = lookup(local.s3_data[terraform.workspace], "block_public_acls", null)
  block_public_policy                  = lookup(local.s3_data[terraform.workspace], "block_public_policy", null)
  ignore_public_acls                   = lookup(local.s3_data[terraform.workspace], "ignore_public_acls", null)
  restrict_public_buckets              = lookup(local.s3_data[terraform.workspace], "restrict_public_buckets", null)
  tags                                 = module.tag_label.tags
}
