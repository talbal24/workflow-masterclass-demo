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

# Injected by env zero from vpc sub-environment outputs
variable "vpc_id" {
  type = string
}

variable "private_subnet_id" {
  type = string
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

resource "aws_security_group" "rds" {
  name   = "${var.environment_name}-rds-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment_name}-rds-sg"
    Environment = var.environment_name
    ManagedBy   = "env0"
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.environment_name}-db-subnet-group"
  subnet_ids = [var.private_subnet_id]
}

resource "aws_db_instance" "main" {
  identifier             = "${var.environment_name}-postgres"
  engine                 = "postgres"
  engine_version         = "15.3"
  instance_class         = var.db_instance_class
  allocated_storage      = 20
  db_name                = "appdb"
  username               = "dbadmin"
  password               = "ChangeMe123!"
  skip_final_snapshot    = true
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  tags = {
    Name        = "${var.environment_name}-postgres"
    Environment = var.environment_name
    ManagedBy   = "env0"
  }
}

# This output flows into the services template
# via env zero variable passing (Environment Output type)
output "db_endpoint" {
  value = aws_db_instance.main.endpoint
}
