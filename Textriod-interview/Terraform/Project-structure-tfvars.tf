TERRAFORM PROJECT STRUCTURE
---------------------------------------------------------------------------------------------------------------------------------------------------
terraform-project/
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── ec2/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
└── env/
    ├── dev/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   ├── backend.tf
    │   └── terraform.tfvars
    │
    ├── stage/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   ├── backend.tf
    │   └── terraform.tfvars
    │
    └── prod/
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        ├── backend.tf
        └── terraform.tfvars
------------------------------------------------------------------------------------------------------------------------------------------------
If backend is used
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"   # S3 bucket name
    key            = "env/dev/terraform.tfstate" # Path inside bucket
    region         = "ap-south-1"                # Region (example: Mumbai)
    dynamodb_table = "terraform-lock"            # DynamoDB table for state locking
    encrypt        = true
  }
}
1. cd terraform-project/env/dev
2. terraform init 
	Download providers, initialize modules, and configure the backend.
 env/
    ├── dev/
    │   ├── .terraform/                 <-- auto-created
    │   │   ├── modules/
    │   │   └── providers/
    │   ├── .terraform.lock.hcl         <-- auto-created
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   ├── backend.tf
    │   └── terraform.tfvars
3. terraform plan
4. terraform apply
env/
    ├── dev/
    │   ├── .terraform/
    │   ├── .terraform.lock.hcl
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   ├── backend.tf
    │   └── terraform.tfvars
    1. terraform init
  -Connects to S3 bucket
  -Creates .terraform/ folder locally
  -Downloads provider inside .terraform
  -Creates .terraform.lock.hcl
2. terraform apply
  -Creates resources in AWS
  -Stores state file into S3 bucket (NOT locally)
  -Stores locking info in DynamoDB table
  -Shows outputs normally
  
  -No local terraform.tfstate file exists
  -No backup state file exists locally
  --------------------------------------------------------------------------------------------------------
  IF NOT BACKEND IS USED
1. cd terraform-project/env/dev
2. terraform init 
	Download providers, initialize modules, and configure the backend.
 env/
    ├── dev/
    │   ├── .terraform/                 <-- auto-created
    │   │   ├── modules/
    │   │   └── providers/
    │   ├── .terraform.lock.hcl         <-- auto-created
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   ├── backend.tf
    │   └── terraform.tfvars
3. terraform plan
4. terraform apply
env/
    ├── dev/
    │   ├── .terraform/
    │   ├── .terraform.lock.hcl
    │   ├── terraform.tfstate           <-- Only if local backend
    │   ├── terraform.tfstate.backup    <-- Backup state
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   ├── backend.tf
    │   └── terraform.tfvars	

  -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 
