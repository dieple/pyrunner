data "aws_iam_policy_document" "bucket_policy" {

  statement {
    principals {
      type        = "AWS"
      identifiers = lookup(local.s3_data[terraform.workspace], "iam_role_arn", null)
    }
    effect = "Allow"
    actions = [
      "s3:Delete*",
      "s3:Get*",
      "s3:List*",
      "s3:*Upload*",
    ]
    resources = [
      "arn:aws:s3:::${local.bucket_name}/*",
      "arn:aws:s3:::${local.bucket_name}",
    ]
  }

  statement {
    principals {
      type        = "AWS"
      identifiers = lookup(local.s3_data[terraform.workspace], "iam_role_arn", null)
    }
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]
    resources = [
      "arn:aws:s3:::${local.bucket_name}/*",
      "arn:aws:s3:::${local.bucket_name}",
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values = [
        "bucket-owner-full-control"
      ]
    }

  }
}
