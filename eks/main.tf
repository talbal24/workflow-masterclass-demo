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

variable "vpc_id" {
  type    = string
  default = ""
}

variable "public_subnet_id" {
  type    = string
  default = ""
}

variable "public_subnet_id_2" {
  type    = string
  default = ""
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

# CD DEMO FIELD: change this to trigger a visible plan diff
variable "desired_node_count" {
  type    = number
  default = 2
}

resource "aws_instance" "app" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_id

  tags = {
    Name        = "${var.environment_name}-app-server"
    Environment = var.environment_name
    ManagedBy   = "env0"
    NodeCount   = tostring(var.desired_node_count)
  }
}

output "cluster_endpoint" {
  value = aws_instance.app.public_dns
}

output "cluster_name" {
  value = "${var.environment_name}-cluster"
}
