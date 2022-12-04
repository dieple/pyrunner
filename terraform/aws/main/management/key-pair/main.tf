module "tag_label" {
  source      = "../../../modules/core/tagging"
  environment = terraform.workspace
  attributes  = ["ssh-key"]
}

module "key_pair" {
  source     = "terraform-aws-modules/key-pair/aws"
  version    = "2.0.0"
  key_name   = module.tag_label.id
  public_key = "ssh-ed25519 YOUR-SSH-PUBLIC-KEY-GO-HERE"
  tags       = module.tag_label.tags
}

module "devops" {
  source     = "terraform-aws-modules/key-pair/aws"
  version    = "2.0.0"
  key_name   = "devops"
  public_key = "ssh-ed25519 YOUR-SSH-PUBLIC-KEY-GO-HERE"
  tags       = module.tag_label.tags
}