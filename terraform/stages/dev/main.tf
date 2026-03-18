terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/../../../src"
  output_path = "${path.module}/../../../dist/lambda.zip"
}

module "sesame_elastic" {
  source = "../../modules"

  project_name        = var.project_name
  environment         = var.environment
  aws_region          = var.aws_region
  availability_zone   = var.availability_zone
  ec2_instance_type   = var.ec2_instance_type
  allowed_ssh_cidr    = var.allowed_ssh_cidr
  allowed_kibana_cidr = var.allowed_kibana_cidr
  sesame_api_key      = var.sesame_api_key
  elk_version         = var.elk_version
  lambda_zip_path     = data.archive_file.lambda.output_path
  schedule_expression = var.schedule_expression
}
