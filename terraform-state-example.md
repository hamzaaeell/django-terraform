# Terraform State File Example

## What's in the State File

```json
{
  "version": 4,
  "terraform_version": "1.5.0",
  "resources": [
    {
      "mode": "managed",
      "type": "aws_vpc",
      "name": "main",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "attributes": {
            "id": "vpc-12345abcde",
            "cidr_block": "10.0.0.0/16",
            "tags": {
              "Name": "dev-devconnector-vpc",
              "Environment": "dev"
            }
          }
        }
      ]
    },
    {
      "mode": "managed", 
      "type": "aws_instance",
      "name": "web",
      "instances": [
        {
          "attributes": {
            "id": "i-1234567890abcdef0",
            "instance_type": "t3.micro",
            "ami": "ami-12345678"
          }
        }
      ]
    }
  ]
}
```

## How Terraform Decides What to Do

### When you run `terraform plan`:

1. **Read state file**: "I know about vpc-12345abcde and i-1234567890abcdef0"
2. **Read .tf files**: "User wants a VPC with 10.0.0.0/16 and t3.micro instance"  
3. **Compare**: 
   - VPC exists and matches → No change needed
   - Instance exists but user changed to t3.small → Needs update
4. **Show plan**: "Will modify 1 resource"

### When you run `terraform apply`:
- Only executes the changes shown in the plan
- Updates state file with new values
- Existing resources remain untouched

## Real-World State Management

```bash
# First deployment
terraform apply
→ Creates: VPC, subnets, RDS, EC2, ALB (all new)
→ State file: Records all resource IDs

# Code change (no infrastructure change)  
git push frontend/
→ Application pipeline runs
→ Infrastructure pipeline DOESN'T run (path-based trigger)
→ State file: Unchanged

# Infrastructure change (increase instance size)
# Change: instance_type = "t3.small"
terraform apply
→ Plan: 0 to add, 1 to change, 0 to destroy
→ Only modifies launch template
→ State file: Updates instance_type attribute
→ VPC, RDS, subnets: Completely untouched

# Add new resource (Redis cache)
# Add: aws_elasticache_cluster resource
terraform apply  
→ Plan: 1 to add, 0 to change, 0 to destroy
→ Creates only the Redis cluster
→ All existing resources: Untouched
```

## State Locking (Important!)

Your backend configuration includes state locking:

```hcl
backend "s3" {
  bucket = "your-terraform-state-bucket"
  key    = "devconnector/dev/terraform.tfstate"
  region = "us-east-1"
  # Terraform automatically creates DynamoDB table for locking
}
```

This prevents:
- Two developers running terraform simultaneously
- GitHub Actions and manual runs conflicting
- State file corruption

## Common Misconceptions

❌ **Wrong**: "Every terraform apply recreates everything"
✅ **Right**: "Terraform only changes what's different"

❌ **Wrong**: "Pushing code triggers infrastructure rebuild"  
✅ **Right**: "Only infrastructure changes trigger infrastructure pipeline"

❌ **Wrong**: "State file stores the actual resources"
✅ **Right**: "State file stores metadata about resources (IDs, attributes)"