locals {
  s3_data = {
    sre = {
      bucket                         = "ld-sync-data"
      acceleration_status            = ""
      acl                            = "private"
      attach_elb_log_delivery_policy = false
      attach_policy                  = true
      block_public_acls              = true
      block_public_policy            = true
      cors_rule                      = {}
      create_bucket                  = true
      force_destroy                  = false
      ignore_public_acls             = true
      logging                        = {}
      policy                         = ""
      replication_configuration      = {}
      request_payer                  = ""
      restrict_public_buckets        = true
      website                        = {}

      iam_role_arn = [
        "arn:aws:iam::${local.org_accounts["sre"]}:user/terraform",
        "arn:aws:iam::${local.org_accounts["sre"]}:role/infra-sre-iam-roles-ec2-dev",
        "arn:aws:iam::${local.org_accounts["dev"]}:role/infra-dev-iam-roles-ec2-dev",
      ]

      server_side_encryption_configuration = {
        rule = {
          apply_server_side_encryption_by_default = {
            sse_algorithm = "AES256"
          }
        }
      }

      lifecycle_rule = [
        {
          id      = "rule1"
          enabled = true

          tags = {
            rule = "rule1"
          }

          transition = [
            {
              storage_class = "STANDARD_IA"
              days          = 30
            },
            {
              days          = 60
              storage_class = "INTELLIGENT_TIERING"
            },
            {
              days          = 90
              storage_class = "ONEZONE_IA"
            },
            {
              days          = 120
              storage_class = "GLACIER"
            },
            {
              days          = 210
              storage_class = "DEEP_ARCHIVE"
            }
          ]

          noncurrent_version_expiration = {
            storage_class = "DEEP_ARCHIVE"
          }
        }

      ]

      versioning = {
        enabled = true
      }

    }
  }

}
