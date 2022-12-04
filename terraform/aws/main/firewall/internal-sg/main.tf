locals {
  use_name_prefix = false
  description     = "Internal private subnet Security group"
  egress_rules    = ["all-all"]

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Internal ssh port"
      cidr_blocks = data.terraform_remote_state.vpc.outputs.vpc_cidr_block
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Your IP white list go here"
      cidr_blocks = "XX.XX.XXX.XX/32" # change to match your env
    },
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

data "terraform_remote_state" "ec2" {
  backend = "s3"

  config = {
    bucket         = lookup(var.envs[terraform.workspace], "bucket")
    key            = format("env:/%s/%s/%s", terraform.workspace, "bastion", "terraform.tfstate")
    region         = lookup(var.envs[terraform.workspace], "bucket_region")
    dynamodb_table = lookup(var.envs[terraform.workspace], "dynamodb")
  }
}

module "tag_label" {
  source      = "../../../modules/core/tagging"
  environment = terraform.workspace
  attributes  = ["internal-sg"]
}

module "internal" {
  source                   = "terraform-aws-modules/security-group/aws"
  version                  = "~> 3.0"
  name                     = module.tag_label.id
  description              = local.description
  vpc_id                   = data.terraform_remote_state.vpc.outputs.vpc_id
  ingress_with_cidr_blocks = local.ingress_with_cidr_blocks
  egress_rules             = local.egress_rules
  use_name_prefix          = local.use_name_prefix
}
