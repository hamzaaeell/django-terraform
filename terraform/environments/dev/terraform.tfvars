# AWS Configuration
aws_region    = "us-east-1"
environment   = "dev"

# Network Configuration
vpc_cidr               = "10.0.0.0/16"
public_subnet_cidrs    = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs   = ["10.0.3.0/24", "10.0.4.0/24"]
availability_zones     = ["us-east-1a", "us-east-1b"]

# Compute Configuration
instance_type          = "t3.micro"
key_pair_name         = "devconnector-dev-key.pem"  # Create this key pair manually in AWS
asg_min_size          = 1
asg_max_size          = 2
asg_desired_capacity  = 1

# Database Configuration
rds_instance_class     = "db.t3.micro"
rds_allocated_storage  = 20
database_password      = "DevConnect2024#Secure"  # AWS RDS compliant password

# Application Configuration
github_repo_url = "https://github.com/hamzaaeell/django-terraform.git"