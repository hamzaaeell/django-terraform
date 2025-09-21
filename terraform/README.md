# DevConnector Infrastructure

This repository contains Terraform modules and configurations for deploying the DevConnector Django-React application across multiple environments (dev, staging, prod) on AWS.

## Architecture Overview

The infrastructure includes:
- **VPC** with public and private subnets across 2 AZs
- **Application Load Balancer** for traffic distribution
- **Auto Scaling Group** with EC2 instances in private subnets
- **RDS PostgreSQL** database in private subnets
- **NAT Gateways** for outbound internet access from private subnets
- **Security Groups** with least privilege access
- **CloudWatch Alarms** for auto scaling

## Directory Structure

```
terraform/
├── modules/
│   ├── vpc/                 # VPC, subnets, routing
│   ├── security-groups/     # Security groups
│   ├── rds/                # RDS PostgreSQL database
│   └── compute/            # ALB, ASG, EC2 instances
└── environments/
    ├── dev/                # Development environment
    ├── staging/            # Staging environment
    └── prod/               # Production environment
```

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **Terraform** >= 1.0 installed
3. **AWS CLI** configured
4. **S3 bucket** for Terraform state storage
5. **EC2 Key Pair** for instance access

## Setup Instructions

### 1. Create S3 Bucket for Terraform State

```bash
aws s3 mb s3://your-terraform-state-bucket
aws s3api put-bucket-versioning \
  --bucket your-terraform-state-bucket \
  --versioning-configuration Status=Enabled
```

### 2. Create EC2 Key Pair

```bash
aws ec2 create-key-pair \
  --key-name devconnector-key \
  --query 'KeyMaterial' \
  --output text > devconnector-key.pem
chmod 400 devconnector-key.pem
```

### 3. Update Configuration Files

Update the following files with your specific values:

- `terraform/environments/*/main.tf` - Update S3 bucket name
- `terraform/environments/*/terraform.tfvars` - Update variables
- `.github/workflows/*.yml` - Update repository URL

### 4. Deploy Infrastructure

#### Development Environment

```bash
cd terraform/environments/dev
terraform init
terraform plan -var="database_password=your-secure-password"
terraform apply
```

#### Staging Environment

```bash
cd terraform/environments/staging
terraform init
terraform plan -var="database_password=your-secure-password"
terraform apply
```

#### Production Environment

```bash
cd terraform/environments/prod
terraform init
terraform plan -var="database_password=your-secure-password"
terraform apply
```

## Environment Specifications

| Environment | Instance Type | RDS Instance | Min/Max ASG | Storage |
|-------------|---------------|--------------|-------------|---------|
| Dev         | t3.micro      | db.t3.micro  | 1/2         | 20GB    |
| Staging     | t3.small      | db.t3.small  | 1/3         | 50GB    |
| Production  | t3.medium     | db.t3.medium | 2/6         | 100GB   |

## CI/CD Pipeline

The GitHub Actions workflows automatically deploy to environments based on branch activity:

- **Development**: Triggered on push to `develop` branch
- **Staging**: Triggered on push to `main` branch
- **Production**: Triggered on release creation or manual dispatch

### Required GitHub Secrets

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_KEY_PAIR_NAME
DEV_DATABASE_PASSWORD
STAGING_DATABASE_PASSWORD
PROD_DATABASE_PASSWORD
SLACK_WEBHOOK_URL (optional)
```

## Security Features

- EC2 instances in private subnets
- RDS in private subnets with encryption
- Security groups with minimal required access
- NAT Gateways for secure outbound access
- ALB with health checks
- Production environment has deletion protection

## Monitoring and Scaling

- CloudWatch alarms for CPU utilization
- Auto scaling policies (scale up at 70% CPU, scale down at 30% CPU)
- ALB health checks for both frontend and backend
- RDS automated backups (7 days dev/staging, 14 days prod)

## Application Deployment

The user data script automatically:
1. Installs Docker, Node.js, Python, and Nginx
2. Clones the application repository
3. Builds the React frontend
4. Configures Django with PostgreSQL
5. Sets up Nginx as reverse proxy
6. Starts all services

## Accessing the Application

After deployment, access your application at the ALB DNS name:
- Frontend: `http://<alb-dns-name>/`
- API: `http://<alb-dns-name>/api/`
- Admin: `http://<alb-dns-name>/admin/`

## Troubleshooting

### Common Issues

1. **Database Connection Errors**
   - Check security group rules
   - Verify database credentials
   - Ensure RDS is in the correct subnets

2. **Application Not Loading**
   - Check ALB target group health
   - Verify user data script execution
   - Check EC2 instance logs

3. **Auto Scaling Issues**
   - Verify CloudWatch alarms
   - Check ASG configuration
   - Review scaling policies

### Useful Commands

```bash
# Check Terraform state
terraform show

# View outputs
terraform output

# Destroy environment (be careful!)
terraform destroy

# SSH to instance (via bastion or VPN)
ssh -i devconnector-key.pem ec2-user@<instance-ip>
```

## Cost Optimization

- Use appropriate instance sizes for each environment
- Enable RDS storage autoscaling
- Set up CloudWatch billing alarms
- Consider using Spot instances for dev/staging
- Review and optimize security group rules

## Maintenance

- Regularly update Terraform modules
- Keep AMIs updated
- Monitor security advisories
- Review and rotate credentials
- Update application dependencies

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review CloudWatch logs
3. Check GitHub Actions workflow logs
4. Contact the DevOps team