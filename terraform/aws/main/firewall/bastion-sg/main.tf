locals {
  use_name_prefix = false
  description     = "Bastion Security group"
  ingress_rules   = ["ssh-tcp"]
  egress_rules    = ["all-all"]
  allow_cidr_block = [
    "XX.XX.XX.XX/32"  # your whitelist IPs
  ]
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket         = lookup(var.envs[terraform.workspace], "bucket")
    key            = format("env:/%s/%s/%s", terraform.workspace, "vpc", "terraform.tfstate")
    region         = lookup(var.envs[terraform.workspace], "bucket_region")
    dynamodb_table = lookup(var.envs[terraform.workspace], "dynamodb")
  }
}

module "tag_label" {
  source      = "../../../modules/core/tagging"
  environment = terraform.workspace
  attributes  = ["bastion-sg"]
}

module "bastion" {
  source              = "terraform-aws-modules/security-group/aws"
  version             = "~> 3.0"
  name                = module.tag_label.id
  description         = local.description
  vpc_id              = data.terraform_remote_state.vpc.outputs.vpc_id
  ingress_cidr_blocks = concat(local.allow_cidr_block, [data.terraform_remote_state.vpc.outputs.vpc_cidr_block])
  ingress_rules       = local.ingress_rules
  egress_rules        = local.egress_rules
  use_name_prefix     = local.use_name_prefix
}
