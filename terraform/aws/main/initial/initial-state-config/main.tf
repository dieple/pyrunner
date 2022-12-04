data "aws_caller_identity" "current" {}

resource "aws_dynamodb_table" "tf_state_dynamodb_lock" {
  name           = "${var.infra_name_prefix}-lock-dynamodb"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_s3_bucket" "tf_state_s3_bucket" {
  bucket = "${var.infra_name_prefix}-bucket"
  acl    = "private"
  #  policy = join("", data.aws_iam_policy_document.default.*.json)
  versioning {
    enabled = true
  }
  lifecycle {
    prevent_destroy = true
  }
  tags = {
    Name      = "${var.infra_name_prefix} S3 Remote Terraform State Store"
    ManagedBy = "terraform"
  }
}