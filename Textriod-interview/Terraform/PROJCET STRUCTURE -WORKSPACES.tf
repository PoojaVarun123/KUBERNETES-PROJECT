terraform-project/
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── backend.tf
│
├── modules/
│   └── ec2/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│
└── env/
    ├── dev.tfvars
    ├── stage.tfvars
    └── prod.tfvars
---------------------------------------------------------------------------------------------------------------------------------------------------
1. terraform init
terraform-project/
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── backend.tf
│
├── .terraform/
│   ├── providers/
│   └── modules/
├── .terraform.lock.hcl
│
├── modules/
│   └── ec2/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
└── env/
    ├── dev.tfvars
    ├── stage.tfvars
    └── prod.tfvars
❌ No state file yet

terraform.tfstate is NOT created during init.
terraform.tfstate.d is NOT created yet.
---------------------------------------------------------------------------------------------------------------------------------------------------
terraform workspace new dev
terraform apply -var-file="env/dev.tfvars"

.terraform/terraform.tfstate.d/dev/terraform.tfstate
[Create .terraform/terraform.tfstate.d/<workspace>]


terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    region         = "ap-south-1"
    dynamodb_table = "terraform_locks"
    key            = "terraform-project/${terraform.workspace}/terraform.tfstate"
    encrypt        = true
  }
}


terraform-project/
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── backend.tf
│
├── .terraform/
│   ├── providers/
│   └── modules/
    └── terraform.tfstate.d/
        ├── dev/terraform.tfstate
        ├── stage/terraform.tfstate
        └── prod/terraform.tfstate
├── .terraform.lock.hcl
│
├── modules/
│   └── ec2/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
└── env/
    ├── dev.tfvars
    ├── stage.tfvars
    └── prod.tfvars


s3://my-terraform-state-bucket/terraform-project/dev/terraform.tfstate
s3://my-terraform-state-bucket/terraform-project/stage/terraform.tfstate
s3://my-terraform-state-bucket/terraform-project/prod/terraform.tfstate
