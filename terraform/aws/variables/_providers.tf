provider "aws" {
  region = lookup(var.envs[terraform.workspace], "region")
}

provider "aws" {
  alias  = "share_r53_iam_role"
  region = lookup(var.envs["master"], "region")
}

provider "aws" {
  alias  = "share_sre_iam_role"
  region = lookup(var.envs["sre"], "region")
}