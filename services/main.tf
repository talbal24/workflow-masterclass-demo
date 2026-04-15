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

variable "cluster_endpoint" {
  type    = string
  default = ""
}

variable "cluster_name" {
  type    = string
  default = ""
}

variable "db_endpoint" {
  type    = string
  default = ""
}

variable "app_version" {
  type    = string
  default = "v1.0.0"
}

variable "app_replica_count" {
  type    = number
  default = 2
}

resource "aws_ssm_parameter" "app_config" {
  name  = "/${var.environment_name}/app/config"
  type  = "String"
  value = jsonencode({
    db_endpoint      = var.db_endpoint
    cluster_endpoint = var.cluster_endpoint
    cluster_name     = var.cluster_name
    app_version      = var.app_version
    replica_count    = var.app_replica_count
    environment      = var.environment_name
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
