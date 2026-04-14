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

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.environment_name}-vpc"
    Environment = var.environment_name
    ManagedBy   = "env0"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 1)
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment_name}-public-subnet-1"
    Environment = var.environment_name
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 3)
  availability_zone       = "${var.aws_region}c"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment_name}-public-subnet-2"
    Environment = var.environment_name
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 2)
  availability_zone = "${var.aws_region}b"

  tags = {
    Name        = "${var.environment_name}-private-subnet"
    Environment = var.environment_name
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment_name}-igw"
    Environment = var.environment_name
  }
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "public_subnet_id_2" {
  value = aws_subnet.public_2.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}
