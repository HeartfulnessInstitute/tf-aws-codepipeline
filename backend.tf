# backend.tf - Terraform Backend Configuration

terraform {
  backend "s3" {
    # Update these values for your setup
    bucket         = "care-state-bucket"      # Replace with your S3 bucket name
    key            = "codepipeline/terraform.tfstate"   # Path to state file in S3
    region         = "ap-south-1"                        # Replace with your AWS region
    encrypt        = true                               # Encrypt state file
    dynamodb_table = "terraform-state-lock"             # DynamoDB table for state locking
    
   
  }
}


