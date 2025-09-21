terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "devconnector-terraform-state-hamzaaeell"
    key    = "devconnector/staging/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  environment            = var.environment
  vpc_cidr              = var.vpc_cidr
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  availability_zones    = var.availability_zones
}

# Security Groups Module
module "security_groups" {
  source = "../../modules/security-groups"

  environment      = var.environment
  vpc_id          = module.vpc.vpc_id
  vpc_cidr_block  = module.vpc.vpc_cidr_block
}

# RDS Module
module "rds" {
  source = "../../modules/rds"

  environment         = var.environment
  private_subnet_ids  = module.vpc.private_subnet_ids
  security_group_id   = module.security_groups.rds_security_group_id
  instance_class      = var.rds_instance_class
  allocated_storage   = var.rds_allocated_storage
  database_password   = var.database_password
}

# Compute Module
module "compute" {
  source = "../../modules/compute"

  environment            = var.environment
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  private_subnet_ids    = module.vpc.private_subnet_ids
  security_group_id     = module.security_groups.ec2_security_group_id
  alb_security_group_id = module.security_groups.alb_security_group_id
  
  instance_type     = var.instance_type
  key_pair_name     = var.key_pair_name
  min_size         = var.asg_min_size
  max_size         = var.asg_max_size
  desired_capacity = var.asg_desired_capacity
  
  db_endpoint      = module.rds.db_instance_endpoint
  db_name         = module.rds.database_name
  db_username     = module.rds.database_username
  db_password     = var.database_password
  github_repo_url = var.github_repo_url
}