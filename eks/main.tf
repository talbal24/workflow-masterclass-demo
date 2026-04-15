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

resource "aws_security_group" "app" {
  name   = "${var.environment_name}-app-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment_name}-app-sg"
    Environment = var.environment_name
    ManagedBy   = "env0"
  }
}

resource "aws_instance" "app" {
  ami                    = "ami-0c02fb55956c7d316" # Amazon Linux 2, us-east-1
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.app.id]

  tags = {
    Name         = "${var.environment_name}-app-server"
    Environment  = var.environment_name
    ManagedBy    = "env0"
    NodeCount    = var.desired_node_count
  }
}

# Outputs consumed by the services template
# via env zero variable passing
output "cluster_endpoint" {
  value = aws_instance.app.public_dns
}

output "cluster_name" {
  value = "${var.environment_name}-cluster"
}
