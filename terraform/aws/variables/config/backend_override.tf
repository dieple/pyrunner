terraform {
  required_version = ">= 0.14.5"

  backend "s3" {
    encrypt = true
  }

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.72"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 1.4"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 2.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.1"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 1.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
  }
}
