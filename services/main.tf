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

# Injected by env zero from eks sub-environment outputs
variable "cluster_endpoint" {
  type = string
}

variable "cluster_name" {
  type = string
}

# Injected by env zero from database sub-environment outputs
variable "db_endpoint" {
  type = string
}

variable "app_version" {
  type    = string
  default = "v1.0.0"
}

# CD DEMO FIELD: change this from 2 to 3, open a PR,
# and show the plan diff appear in GitHub + in env zero
variable "app_replica_count" {
  type    = number
  default = 2
}

# This SSM parameter makes the variable passing visible and concrete —
# it stores the db endpoint and cluster info as parameters
# that the app would read at runtime
resource "aws_ssm_parameter" "db_endpoint" {
  name  = "/${var.environment_name}/app/db_endpoint"
  type  = "String"
  value = var.db_endpoint

  tags = {
    Environment = var.environment_name
    ManagedBy   = "env0"
  }
}

resource "aws_ssm_parameter" "cluster_endpoint" {
  name  = "/${var.environment_name}/app/cluster_endpoint"
  type  = "String"
  value = var.cluster_endpoint

  tags = {
    Environment = var.environment_name
    ManagedBy   = "env0"
  }
}

resource "aws_ssm_parameter" "app_config" {
  name  = "/${var.environment_name}/app/config"
  type  = "String"
  value = jsonencode({
    cluster_name   = var.cluster_name
    app_version    = var.app_version
    replica_count  = var.app_replica_count
    environment    = var.environment_name
  })

  tags = {
    Environment = var.environment_name
    ManagedBy   = "env0"
  }
}

output "app_version" {
  value = var.app_version
}

output "replica_count" {
  value = var.app_replica_count
}

output "db_param_path" {
  value = aws_ssm_parameter.db_endpoint.name
}
