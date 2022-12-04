data "aws_iam_policy_document" "default" {
  statement {
    sid = "AWSBucketOwner"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/terraform"
      ]
    }
    actions = [
      "s3:PutObject",
      "s3:GetBucketAcl",
      "s3:List*",
      "s3:Get*",
    ]
    resources = [
      "arn:aws:s3:::ld-tf-state-bucket/*",
    ]
    #    condition {
    #      test     = "StringEquals"
    #      variable = "s3:x-amz-acl"
    #
    #      values = [
    #        "bucket-owner-full-control",
    #      ]
    #    }
  }

  statement {
    sid = "StmtAWSListBucket"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/terraform"
      ]
    }
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::tf-state-bucket",
    ]
  }

}
