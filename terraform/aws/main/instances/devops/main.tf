locals {
  common_tags = {
    ClusterName = module.tag_label.id
  }

  ec2_data = {
    sre = {
      ami                         = "ami-xxxxxxxxxxxxxxxxx" # Rocky Linux 9 (Official)
      associate_public_ip_address = false
      iam_instance_profile        = module.iam.iam_instance_profile_name
      instance_type               = "t3.xlarge"
      key_name                    = data.terraform_remote_state.key.outputs.devops_key_name
      monitoring                  = true
      name                        = module.tag_label.id
      availability_zone           = data.terraform_remote_state.vpc.outputs.azs[0]
      subnet_id                   = data.terraform_remote_state.vpc.outputs.private_subnets[0]
      vpc_security_group_ids      = [data.terraform_remote_state.sg.outputs.security_group_id]
      volume_tags                 = module.tag_label.tags

      root_block_device = [
        {
          encrypted   = true
          volume_type = "gp3"
          throughput  = 200
          volume_size = 500
          encrypted   = true
          kms_key_id  = try(lookup(data.terraform_remote_state.kms.outputs.alias_map, "alias/defi-${terraform.workspace}", null))
        }
      ]
    }
  }
}

data "terraform_remote_state" "sg" {
  backend = "s3"

  config = {
    bucket         = lookup(var.envs[terraform.workspace], "bucket")
    key            = format("env:/%s/%s/%s", terraform.workspace, "internal-sg", "terraform.tfstate")
    region         = lookup(var.envs[terraform.workspace], "bucket_region")
    dynamodb_table = lookup(var.envs[terraform.workspace], "dynamodb")
  }
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

module "iam" {
  source                 = "../../../modules/iam/role"
  enabled                = true
  create_ec2_profile     = true
  name                   = format("%s-%s", module.tag_label.id, "ec2")
  policy_description     = "Allow ec2 instances to access S3 bucket"
  role_description       = "IAM role with permissions to interact resources on S3 bucket"
  policy_documents       = [data.aws_iam_policy_document.ec2.json]
  additional_policy_arns = []
  tags                   = local.tags

  principals = {
    Service = ["ec2.amazonaws.com"]
  }
}

data "terraform_remote_state" "kms" {
  backend = "s3"

  config = {
    bucket         = lookup(var.envs[terraform.workspace], "bucket")
    key            = format("env:/%s/%s/%s", terraform.workspace, "kms", "terraform.tfstate")
    region         = lookup(var.envs[terraform.workspace], "bucket_region")
    dynamodb_table = lookup(var.envs[terraform.workspace], "dynamodb")
  }
}

data "terraform_remote_state" "key" {
  backend = "s3"

  config = {
    bucket         = lookup(var.envs[terraform.workspace], "bucket")
    key            = format("env:/%s/%s/%s", terraform.workspace, "key-pair", "terraform.tfstate")
    region         = lookup(var.envs[terraform.workspace], "bucket_region")
    dynamodb_table = lookup(var.envs[terraform.workspace], "dynamodb")
  }
}

module "tag_label" {
  source      = "../../../modules/core/tagging"
  environment = terraform.workspace
  attributes  = ["devops"]
  tags        = local.common_tags
}

resource "aws_volume_attachment" "this" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.this.id
  instance_id = module.ec2_instance.id
  depends_on  = [module.ec2_instance]
}

resource "aws_ebs_volume" "this" {
  availability_zone = lookup(local.ec2_data[terraform.workspace], "availability_zone")
  encrypted         = true
  type              = "gp3"
  size              = 2000
  kms_key_id        = try(lookup(data.terraform_remote_state.kms.outputs.alias_map, "alias/defi-${terraform.workspace}", null))
  tags              = module.tag_label.tags
  depends_on        = [module.ec2_instance]
}

module "ec2_instance" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "4.1.4"
  name                        = module.tag_label.id
  ami                         = lookup(local.ec2_data[terraform.workspace], "ami")
  associate_public_ip_address = lookup(local.ec2_data[terraform.workspace], "associate_public_ip_address")
  iam_instance_profile        = lookup(local.ec2_data[terraform.workspace], "iam_instance_profile")
  instance_type               = lookup(local.ec2_data[terraform.workspace], "instance_type")
  root_block_device           = lookup(local.ec2_data[terraform.workspace], "root_block_device")
  key_name                    = lookup(local.ec2_data[terraform.workspace], "key_name")
  monitoring                  = lookup(local.ec2_data[terraform.workspace], "monitoring")
  availability_zone           = lookup(local.ec2_data[terraform.workspace], "availability_zone")
  subnet_id                   = lookup(local.ec2_data[terraform.workspace], "subnet_id")
  vpc_security_group_ids      = lookup(local.ec2_data[terraform.workspace], "vpc_security_group_ids")
  volume_tags                 = lookup(local.ec2_data[terraform.workspace], "volume_tags")
  tags                        = module.tag_label.tags
}