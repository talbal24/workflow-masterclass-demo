terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "environment_name" {
  type    = string
  default = "demo"
}

# Passed from vpc sub-environment via env zero variable passing
variable "vpc_id" {
  type = string
}

resource "aws_ssm_parameter" "db_endpoint" {
  name  = "/${var.environment_name}/db/endpoint"
  type  = "String"
  value = "${var.environment_name}-db.demo.internal"

  tags = {
    Environment = var.environment_name
    ManagedBy   = "env0"
    VPC         = var.vpc_id
  }
}

# This output flows into the services template
output "db_endpoint" {
  value = aws_ssm_parameter.db_endpoint.value
  sensitive = true
}
