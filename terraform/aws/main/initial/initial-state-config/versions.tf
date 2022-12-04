terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.0.0"
      //configuration_aliases = [ aws.alternate ]
    }
  }
  required_version = ">= 0.14"
}