locals {
  user_data = []

  ec2_data = {
    sre = {
      sgid                        = [data.terraform_remote_state.sg.outputs.security_group_id]
      ami_id                      = "ami-xxxxxxxxxxxxxxxxx" # base ami built by packer - change to match your env
      instance_type               = "t3.micro"
      create_ec2_ssm_iam_role     = true
      ssh_user                    = "rocky"
      volume_size                 = "30"
      max_size                    = "1"
      min_size                    = "1"
      desired_capacity            = "1"
      wait_for_capacity_timeout   = "10m"
      cooldown                    = "300"
      health_check_grace_period   = "300"
      scale_down_cron             = "0 23 * * *"
      scale_up_cron               = "0 7 * * MON-FRI"
      scale_down_min_size         = "1"
      scale_down_desired_capacity = "1"
      jump_alias                  = ""
      key_name                    = data.terraform_remote_state.key.outputs.key_name
      public_subnets              = data.terraform_remote_state.vpc.outputs.public_subnets
      vpc_id                      = data.terraform_remote_state.vpc.outputs.vpc_id
    }
    qa = {
      sgid                        = [data.terraform_remote_state.sg.outputs.security_group_id]
      ami_id                      = data.aws_ami.rocky.id
      instance_type               = "t3.micro"
      create_ec2_ssm_iam_role     = true
      ssh_user                    = "rocky"
      volume_size                 = "30"
      max_size                    = "1"
      min_size                    = "1"
      desired_capacity            = "1"
      wait_for_capacity_timeout   = "10m"
      cooldown                    = "300"
      health_check_grace_period   = "300"
      scale_down_cron             = "0 23 * * *"
      scale_up_cron               = "0 7 * * MON-FRI"
      scale_down_min_size         = "1"
      scale_down_desired_capacity = "1"
      jump_alias                  = ""
      key_name                    = data.terraform_remote_state.key.outputs.key_name
      public_subnets              = data.terraform_remote_state.vpc.outputs.public_subnets
      vpc_id                      = data.terraform_remote_state.vpc.outputs.vpc_id
    }
    dev = {
      sgid                        = [data.terraform_remote_state.sg.outputs.security_group_id]
      ami_id                      = "ami-xxxxxxxxxxxxxxxxx" # base ami built by packer - change to match your env
      instance_type               = "t3.micro"
      create_ec2_ssm_iam_role     = true
      ssh_user                    = "rocky"
      volume_size                 = "30"
      max_size                    = "1"
      min_size                    = "1"
      desired_capacity            = "1"
      wait_for_capacity_timeout   = "10m"
      cooldown                    = "300"
      health_check_grace_period   = "300"
      scale_down_cron             = "0 23 * * *"
      scale_up_cron               = "0 7 * * MON-FRI"
      scale_down_min_size         = "1"
      scale_down_desired_capacity = "1"
      jump_alias                  = ""
      key_name                    = data.terraform_remote_state.key.outputs.key_name
      public_subnets              = data.terraform_remote_state.vpc.outputs.public_subnets
      vpc_id                      = data.terraform_remote_state.vpc.outputs.vpc_id
    }
    stg = {
      sgid                        = [data.terraform_remote_state.sg.outputs.security_group_id]
      ami_id                      = "ami-xxxxxxxxxxxxxxxxx" # base ami built by packer - change to match your env
      instance_type               = "t3.micro"
      create_ec2_ssm_iam_role     = true
      ssh_user                    = "rocky"
      volume_size                 = "30"
      max_size                    = "1"
      min_size                    = "1"
      desired_capacity            = "1"
      wait_for_capacity_timeout   = "10m"
      cooldown                    = "300"
      health_check_grace_period   = "300"
      scale_down_cron             = "0 23 * * *"
      scale_up_cron               = "0 7 * * MON-FRI"
      scale_down_min_size         = "1"
      scale_down_desired_capacity = "1"
      jump_alias                  = ""
      key_name                    = data.terraform_remote_state.key.outputs.key_name
      public_subnets              = data.terraform_remote_state.vpc.outputs.public_subnets
      vpc_id                      = data.terraform_remote_state.vpc.outputs.vpc_id
    }
    prod = {
      sgid                        = [data.terraform_remote_state.sg.outputs.security_group_id]
      ami_id                      = "ami-xxxxxxxxxxxxxxxxx" # base ami built by packer - change to match your env
      instance_type               = "t3.micro"
      create_ec2_ssm_iam_role     = true
      ssh_user                    = "rocky"
      volume_size                 = "30"
      max_size                    = "1"
      min_size                    = "1"
      desired_capacity            = "1"
      wait_for_capacity_timeout   = "10m"
      cooldown                    = "300"
      health_check_grace_period   = "300"
      scale_down_cron             = "0 23 * * *"
      scale_up_cron               = "0 7 * * MON-FRI"
      scale_down_min_size         = "1"
      scale_down_desired_capacity = "1"
      jump_alias                  = ""
      key_name                    = data.terraform_remote_state.key.outputs.key_name
      public_subnets              = data.terraform_remote_state.vpc.outputs.public_subnets
      vpc_id                      = data.terraform_remote_state.vpc.outputs.vpc_id
    }

  }
}

data "aws_region" "current" {}

# Rocky Linux
data "aws_ami" "rocky" {
  most_recent = true
  owners      = ["792107900819"] // Rocky Linux

  filter {
    name   = "name"
    values = ["Rocky-9-EC2-9.0-*x86_64"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "tag_label" {
  source      = "../../../modules/core/tagging"
  environment = terraform.workspace
  attributes  = ["bastion"]
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

data "terraform_remote_state" "sg" {
  backend = "s3"

  config = {
    bucket         = lookup(var.envs[terraform.workspace], "bucket")
    key            = format("env:/%s/%s/%s", terraform.workspace, "bastion-sg", "terraform.tfstate")
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

data "template_file" "bastion_init_script" {
  template = file("${path.module}/user_data/user_data.yaml")

  vars = {
    allocation_id = aws_eip.bastion.id
    user_data     = join("\n", local.user_data)
    region        = data.aws_region.current.name
  }
}

# EIP for instances
resource "aws_eip" "bastion" {
  vpc  = true
  tags = module.tag_label.tags
}

data "aws_instance" "this" {
  filter {
    name   = "tag:Name"
    values = [module.tag_label.id]
  }

  filter {
    name   = "instance-state-name"
    values = ["running", "pending"]
  }

  depends_on = [module.bastion]
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = data.aws_instance.this.id
  allocation_id = aws_eip.bastion.id
  depends_on    = [module.bastion]
}

module "bastion" {
  source                      = "../../../modules/instances/bastion"
  bastion_name                = module.tag_label.id
  ami_id                      = lookup(local.ec2_data[terraform.workspace], "ami_id")
  instance_type               = lookup(local.ec2_data[terraform.workspace], "instance_type")
  public_subnets              = lookup(local.ec2_data[terraform.workspace], "public_subnets")
  vpc_id                      = lookup(local.ec2_data[terraform.workspace], "vpc_id")
  security_groups             = lookup(local.ec2_data[terraform.workspace], "sgid")
  ssh_user                    = lookup(local.ec2_data[terraform.workspace], "ssh_user")
  user_data                   = data.template_file.bastion_init_script.rendered
  volume_size                 = lookup(local.ec2_data[terraform.workspace], "volume_size")
  max_size                    = lookup(local.ec2_data[terraform.workspace], "max_size")
  min_size                    = lookup(local.ec2_data[terraform.workspace], "min_size")
  desired_capacity            = lookup(local.ec2_data[terraform.workspace], "desired_capacity")
  wait_for_capacity_timeout   = lookup(local.ec2_data[terraform.workspace], "wait_for_capacity_timeout")
  cooldown                    = lookup(local.ec2_data[terraform.workspace], "cooldown")
  key_name                    = lookup(local.ec2_data[terraform.workspace], "key_name")
  health_check_grace_period   = lookup(local.ec2_data[terraform.workspace], "health_check_grace_period")
  scale_down_cron             = lookup(local.ec2_data[terraform.workspace], "scale_down_cron")
  scale_up_cron               = lookup(local.ec2_data[terraform.workspace], "scale_up_cron")
  scale_down_min_size         = lookup(local.ec2_data[terraform.workspace], "scale_down_min_size")
  scale_down_desired_capacity = lookup(local.ec2_data[terraform.workspace], "scale_down_desired_capacity")
  environment                 = terraform.workspace
  tags                        = module.tag_label.tags
}
