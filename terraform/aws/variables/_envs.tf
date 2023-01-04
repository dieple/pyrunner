# Keep this file in sync with ../../../../../workspaces.json

variable "envs" {
  type = map(any)

  default = {

    master = {
      account_id         = "111111111111"
      account            = "MASTER Account"
      workspace_iam_role = "arn:aws:iam::111111111111:role/administrators"
      share_sre_iam_role = "arn:aws:iam::222222222222:role/administrators"
      share_r53_iam_role = "arn:aws:iam::111111111111:role/administrators"
      region             = "eu-west-2"
      bucket_region      = "eu-west-2"
      bucket             = "terraform-state-bucket",
      dynamodb           = "terraform-state-lock-dynamodb"
    }

    sre = {
      account_id         = "2222222222222"
      account            = "SRE/DEVOPS CI/CD AWS resources build account (LONDON)"
      workspace_iam_role = "arn:aws:iam::222222222222:role/administrators" # use role/OrganizationAccountAccessRole for `initial-iam-roles`
      share_sre_iam_role = "arn:aws:iam::222222222222:role/administrators"
      share_r53_iam_role = "arn:aws:iam::111111111111:role/administrators"
      region             = "eu-west-2"
      bucket_region      = "eu-west-2"
      bucket             = "terraform-state-bucket",
      dynamodb           = "terraform-state-lock-dynamodb"
    }

    dev = {
      account_id         = "555555555555"
      account            = "DEVELOPMENT Environment (LONDON)"
      workspace_iam_role = "arn:aws:iam::555555555555:role/administrators" # use role/OrganizationAccountAccessRole for `initial-iam-roles`
      share_sre_iam_role = "arn:aws:iam::222222222222:role/administrators"
      share_r53_iam_role = "arn:aws:iam::111111111111:role/administrators"
      region             = "eu-west-2"
      bucket_region      = "eu-west-2"
      bucket             = "terraform-state-bucket",
      dynamodb           = "terraform-state-lock-dynamodb"
    }

    stg = {
      account_id         = "666666666666"
      account            = "STAGING Environment (TOKYO)"
      workspace_iam_role = "arn:aws:iam::666666666666:role/administrators" # use role/OrganizationAccountAccessRole for `initial-iam-roles`
      share_sre_iam_role = "arn:aws:iam::222222222222:role/administrators"
      share_r53_iam_role = "arn:aws:iam::111111111111:role/administrators"
      region             = "ap-northeast-1"
      bucket_region      = "eu-west-2"
      bucket             = "terraform-state-bucket",
      dynamodb           = "terraform-state-lock-dynamodb"
    }

    qa = {
      account_id         = "777777777777"
      account            = "QA Environment (LONDON)"
      workspace_iam_role = "arn:aws:iam::777777777777:role/administrators" # use role/OrganizationAccountAccessRole for `initial-iam-roles`
      share_sre_iam_role = "arn:aws:iam::222222222222:role/administrators"
      share_r53_iam_role = "arn:aws:iam::111111111111:role/administrators"
      region             = "eu-west-2"
      bucket_region      = "eu-west-2"
      bucket             = "terraform-state-bucket",
      dynamodb           = "terraform-state-lock-dynamodb"
    }

    prod = {
      account_id         = "888888888888"
      account            = "PRODUCTION Environment (TOKYO)"
      workspace_iam_role = "arn:aws:iam::888888888888:role/administrators" # use role/OrganizationAccountAccessRole for `initial-iam-roles`
      share_sre_iam_role = "arn:aws:iam::222222222222:role/administrators"
      share_r53_iam_role = "arn:aws:iam::111111111111:role/administrators"
      region             = "ap-northeast-1"
      bucket_region      = "eu-west-2"
      bucket             = "terraform-state-bucket",
      dynamodb           = "terraform-state-lock-dynamodb"
    }

  }
}