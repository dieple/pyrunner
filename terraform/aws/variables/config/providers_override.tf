provider "aws" {
  region = lookup(var.envs[terraform.workspace], "region")
  # switch role to destination `terraform.workspace` to build resources
  assume_role {
    role_arn = lookup(var.envs[terraform.workspace], "workspace_iam_role")
  }
}

provider "aws" {
  alias  = "share_r53_iam_role"
  region = lookup(var.envs["master"], "region")

  assume_role {
    role_arn = lookup(var.envs[terraform.workspace], "share_r53_iam_role")
  }
}

provider "aws" {
  alias  = "share_sre_iam_role"
  region = lookup(var.envs["sre"], "region")

  assume_role {
    role_arn = lookup(var.envs["sre"], "share_sre_iam_role")
  }
}
