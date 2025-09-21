# State File Flow in GitHub Actions

## What Happens During `terraform init`

### Dev Pipeline:
```bash
cd terraform/environments/dev
terraform init
```

**Behind the scenes:**
1. Reads `main.tf` backend configuration
2. Connects to S3: `s3://your-terraform-state-bucket/devconnector/dev/terraform.tfstate`
3. Downloads the dev state file to local `.terraform/` directory
4. Sets up state locking with DynamoDB

### Staging Pipeline:
```bash
cd terraform/environments/staging  
terraform init
```

**Behind the scenes:**
1. Reads `main.tf` backend configuration
2. Connects to S3: `s3://your-terraform-state-bucket/devconnector/staging/terraform.tfstate`
3. Downloads the staging state file to local `.terraform/` directory
4. Sets up state locking with DynamoDB

### Production Pipeline:
```bash
cd terraform/environments/prod
terraform init
```

**Behind the scenes:**
1. Reads `main.tf` backend configuration  
2. Connects to S3: `s3://your-terraform-state-bucket/devconnector/prod/terraform.tfstate`
3. Downloads the prod state file to local `.terraform/` directory
4. Sets up state locking with DynamoDB

## What Happens During `terraform plan`

Each pipeline then:

1. **Reads current state** (from the downloaded state file)
2. **Reads desired state** (from .tf files + .tfvars)
3. **Compares them** to determine what changes are needed
4. **Shows the plan** (add/change/destroy)

## Example: You Change Dev Instance Type

```
Change: terraform/environments/dev/terraform.tfvars
instance_type = "t3.small"  # was t3.micro
```

### All 3 Pipelines Run:

**Dev Pipeline:**
```bash
terraform init  # Downloads dev state file
terraform plan  # Compares:
                # Current state: instance_type = "t3.micro" 
                # Desired state: instance_type = "t3.small"
                # Result: "Plan: 0 to add, 1 to change, 0 to destroy"
```

**Staging Pipeline:**
```bash
terraform init  # Downloads staging state file  
terraform plan  # Compares:
                # Current state: instance_type = "t3.micro"
                # Desired state: instance_type = "t3.micro" (from staging.tfvars)
                # Result: "No changes. Infrastructure matches configuration."
```

**Production Pipeline:**
```bash
terraform init  # Downloads prod state file
terraform plan  # Compares:
                # Current state: instance_type = "t3.micro"
                # Desired state: instance_type = "t3.micro" (from prod.tfvars)  
                # Result: "No changes. Infrastructure matches configuration."
```

## State File Isolation Visualization

```
GitHub Actions Runner (Dev Pipeline)
├── Working Directory: terraform/environments/dev/
├── Downloads: s3://bucket/devconnector/dev/terraform.tfstate
├── Reads: terraform.tfvars (dev values)
└── Compares: dev state vs dev config

GitHub Actions Runner (Staging Pipeline)  
├── Working Directory: terraform/environments/staging/
├── Downloads: s3://bucket/devconnector/staging/terraform.tfstate
├── Reads: terraform.tfvars (staging values)
└── Compares: staging state vs staging config

GitHub Actions Runner (Prod Pipeline)
├── Working Directory: terraform/environments/prod/
├── Downloads: s3://bucket/devconnector/prod/terraform.tfstate  
├── Reads: terraform.tfvars (prod values)
└── Compares: prod state vs prod config
```

## Key Point: State File = Source of Truth

Each environment's state file contains:
- Resource IDs (vpc-123, i-456, etc.)
- Current configuration values
- Resource dependencies
- Metadata

When terraform compares "current state vs desired state", it's comparing:
- **Current state**: What's in the downloaded state file
- **Desired state**: What's in your .tf files + .tfvars

This is exactly how Terraform knows whether to create, update, or skip resources!