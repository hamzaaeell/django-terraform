#!/bin/bash

# Test AWS Credentials Script
echo "🔐 Testing AWS Credentials..."

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found. Please install it first:"
    echo "   brew install awscli  # macOS"
    echo "   pip install awscli   # Python"
    exit 1
fi

# Set credentials temporarily for testing
echo "Enter your AWS Access Key ID:"
read -r AWS_ACCESS_KEY_ID
echo "Enter your AWS Secret Access Key:"
read -rs AWS_SECRET_ACCESS_KEY

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION=us-east-1

echo
echo "🧪 Testing AWS connection..."

# Test basic AWS access
if aws sts get-caller-identity > /dev/null 2>&1; then
    echo "✅ AWS credentials are valid!"
    
    # Show account info
    echo "📋 Account Information:"
    aws sts get-caller-identity --output table
    
    # Test required permissions
    echo
    echo "🔍 Testing required permissions..."
    
    # Test EC2 permissions
    if aws ec2 describe-regions --region us-east-1 > /dev/null 2>&1; then
        echo "✅ EC2 permissions: OK"
    else
        echo "❌ EC2 permissions: FAILED"
    fi
    
    # Test VPC permissions
    if aws ec2 describe-vpcs --region us-east-1 > /dev/null 2>&1; then
        echo "✅ VPC permissions: OK"
    else
        echo "❌ VPC permissions: FAILED"
    fi
    
    # Test RDS permissions
    if aws rds describe-db-instances --region us-east-1 > /dev/null 2>&1; then
        echo "✅ RDS permissions: OK"
    else
        echo "❌ RDS permissions: FAILED"
    fi
    
    # Test S3 permissions
    if aws s3 ls > /dev/null 2>&1; then
        echo "✅ S3 permissions: OK"
    else
        echo "❌ S3 permissions: FAILED"
    fi
    
else
    echo "❌ AWS credentials are invalid or insufficient permissions!"
    echo "Please check:"
    echo "1. Access Key ID is correct"
    echo "2. Secret Access Key is correct"
    echo "3. User has required permissions (EC2, VPC, RDS, S3, IAM)"
    exit 1
fi

echo
echo "🎉 AWS credentials test completed!"
echo "You can now safely add these to GitHub Secrets."