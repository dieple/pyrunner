locals {

  eks_worker_iam_role_arn = [
    data.terraform_remote_state.eks_roles.outputs.eks_workers_iam_role_arn
  ]

  # `local.org_accounts` is linked at runtime by the files variables/_accounts.tf
  allowed_account_ids  = [for name, id in local.org_accounts : id]
  allow_push           = true
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true
  max_image_count      = 30

  repository_names = [
    "ci/infra-base",
    "ci/alpine-base",
    "ci/rocky-base",
  ]
}

module "tag_label" {
  source = "../../../modules/core/tagging"

  environment = terraform.workspace
  attributes  = ["ecr-repos"]
  tags        = {}
}

data "terraform_remote_state" "eks_roles" {
  backend = "s3"

  config = {
    bucket         = lookup(var.envs[terraform.workspace], "bucket")
    key            = format("env:/%s/%s/%s", "sre", "roles", "terraform.tfstate")
    region         = lookup(var.envs[terraform.workspace], "bucket_region")
    dynamodb_table = lookup(var.envs[terraform.workspace], "dynamodb")
  }
}

# the name of the created dynamodb will be the result of module.tag_label.id
module "ecr_repos" {
  source = "../../../modules/containers/ecr-repositories"

  allowed_account_ids     = local.allowed_account_ids
  repository_names        = local.repository_names
  allow_push              = local.allow_push
  image_tag_mutability    = local.image_tag_mutability
  scan_on_push            = local.scan_on_push
  max_image_count         = local.max_image_count
  eks_worker_iam_role_arn = local.eks_worker_iam_role_arn
  tags                    = module.tag_label.tags
}
