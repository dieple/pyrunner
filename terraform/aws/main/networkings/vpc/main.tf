locals {
  region_name = data.aws_region.current.name

  common_tags = {
    ClusterName = module.tag_label_eks.id
  }
}

module "tag_label" {
  source      = "../../../modules/core/tagging"
  environment = terraform.workspace
  attributes  = ["vpc"]
}

module "tag_label_eks" {
  source      = "../../../modules/core/tagging"
  environment = terraform.workspace
  attributes  = ["eks"]
  tags        = local.common_tags
}

module "vpc" {
  source                               = "../../../modules/networkings/vpc"
  name                                 = module.tag_label.id
  cidr                                 = lookup(local.vpc_data[terraform.workspace], "cidr")
  azs                                  = slice(data.aws_availability_zones.available.names, 0, lookup(local.vpc_data[terraform.workspace], "azs_count"))
  public_subnet_suffix                 = lookup(local.vpc_data[terraform.workspace], "public_subnet_suffix")
  private_subnet_suffix                = lookup(local.vpc_data[terraform.workspace], "private_subnet_suffix")
  public_subnets                       = lookup(local.vpc_data[terraform.workspace], "public_subnets")
  private_subnets                      = lookup(local.vpc_data[terraform.workspace], "private_subnets")
  enable_nat_gateway                   = lookup(local.vpc_data[terraform.workspace], "enable_nat_gateway")
  one_nat_gateway_per_az               = lookup(local.vpc_data[terraform.workspace], "one_nat_gateway_per_az")
  enable_dns_hostnames                 = lookup(local.vpc_data[terraform.workspace], "enable_dns_hostnames")
  enable_dns_support                   = lookup(local.vpc_data[terraform.workspace], "enable_dns_support")
  enable_dhcp_options                  = lookup(local.vpc_data[terraform.workspace], "enable_dhcp_options")
  dhcp_options_domain_name             = "${data.aws_region.current.name}.compute.internal"
  enable_flow_log                      = lookup(local.vpc_data[terraform.workspace], "enable_flow_log")
  create_flow_log_cloudwatch_log_group = lookup(local.vpc_data[terraform.workspace], "create_flow_log_cloudwatch_log_group")
  create_flow_log_cloudwatch_iam_role  = lookup(local.vpc_data[terraform.workspace], "create_flow_log_cloudwatch_iam_role")
  flow_log_max_aggregation_interval    = lookup(local.vpc_data[terraform.workspace], "flow_log_max_aggregation_interval")
  tags                                 = module.tag_label.tags
  vpc_flow_log_tags                    = module.tag_label.tags

  vpc_tags = {
    "kubernetes.io/cluster/${module.tag_label_eks.id}" = lookup(local.vpc_data[terraform.workspace], "shared_tag")
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${module.tag_label_eks.id}" = lookup(local.vpc_data[terraform.workspace], "shared_tag")
    "kubernetes.io/role/elb"                           = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${module.tag_label_eks.id}" = lookup(local.vpc_data[terraform.workspace], "shared_tag")
    "kubernetes.io/role/internal-elb"                  = "1"
  }
}

module "vpc_endpoints" {
  source             = "../../../modules/networkings/vpc-endpoints"
  vpc_id             = module.vpc.vpc_id
  security_group_ids = [data.aws_security_group.default.id]

  endpoints = {
    s3 = {
      service = "s3"
      tags    = { Name = "s3-vpc-endpoint" }
    },
    #    dynamodb = {
    #      service         = "dynamodb"
    #      service_type    = "Gateway"
    #      route_table_ids = flatten([module.vpc.intra_route_table_ids, module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
    #      policy          = data.aws_iam_policy_document.dynamodb_endpoint_policy.json
    #      tags            = { Name = "dynamodb-vpc-endpoint" }
    #    },
    #    ssm = {
    #      service = "ssm"
    #      #      private_dns_enabled = true
    #      subnet_ids = module.vpc.private_subnets
    #      tags       = { Name = "ssm-vpc-endpoint" }
    #    },
    #    lambda = {
    #      service             = "lambda"
    #      private_dns_enabled = true
    #      subnet_ids          = module.vpc.private_subnets
    #      tags                = { Name = "lambda-vpc-endpoint" }
    #    },
    #    ecs = {
    #      service             = "ecs"
    #      private_dns_enabled = true
    #      subnet_ids          = module.vpc.private_subnets
    #      tags                = { Name = "ecs-vpc-endpoint" }
    #    },
    #    ec2 = {
    #      service             = "ec2"
    #      private_dns_enabled = true
    #      subnet_ids          = module.vpc.private_subnets
    #      tags                = { Name = "ec2-vpc-endpoint" }
    #    },
    #    ecr_api = {
    #      service             = "ecr.api"
    #      private_dns_enabled = true
    #      subnet_ids          = module.vpc.private_subnets
    #      policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
    #      tags                = { Name = "ecr_api-vpc-endpoint" }
    #    },
    #    ecr_dkr = {
    #      service             = "ecr.dkr"
    #      private_dns_enabled = true
    #      subnet_ids          = module.vpc.private_subnets
    #      #policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
    #      tags = { Name = "ecr_dkr-vpc-endpoint" }
    #    },
    #    kms = {
    #      service             = "kms"
    #      private_dns_enabled = true
    #      subnet_ids          = module.vpc.private_subnets
    #      tags                = { Name = "kms-vpc-endpoint" }
    #    },
    #    logs = {
    #      service             = "logs"
    #      private_dns_enabled = true
    #      subnet_ids          = module.vpc.private_subnets
    #      tags                = { Name = "logs-vpc-endpoint" }
    #    },
    #    secretsmanager = {
    #      service             = "secretsmanager"
    #      private_dns_enabled = true
    #      subnet_ids          = module.vpc.private_subnets
    #      tags                = { Name = "secretsmanager-vpc-endpoint" }
    #    },
  }

  tags = module.tag_label.tags
}
