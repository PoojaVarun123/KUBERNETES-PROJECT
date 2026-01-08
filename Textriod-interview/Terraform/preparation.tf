Terraform
	-Terraform oss or Cloud or enterprise
	-Terraform version
	
-------------------------------------------------------------------------------------------------
1. Features of Terraform
	-Infrastructure as Code using declarative configuration
	-Multi-cloud and provider-based architecture
	-State management and resource tracking
	-Execution plans (plan vs apply)
	-Dependency graph and parallel execution
	-Modular and reusable configurations
	-Drift detection
	-Change automation and CI/CD integration
	-Policy enforcement and governance (Cloud/Enterprise)

Terraform is an Infrastructure as Code tool that lets you define infrastructure declaratively and manage it in a version-controlled, 
repeatable way. It supports multiple cloud providers through a plugin-based provider model and uses a state file to track real infrastructure. 
Terraform generates an execution plan before applying changes, which helps prevent unintended updates. It automatically manages dependencies 
and supports modular, reusable configurations. Terraform integrates well with CI/CD pipelines, and with Terraform Cloud or Enterprise it adds 
governance features like approvals, policies, and audit logs for safe production deployments.
-----------------------------------------------------------------------------------------------------------------------------------------------------
Revert PR - Merge to main - Pipeline runs:terraform plan - approval-terraform apply
---------------------------------------------------------------------------------------------------------------------------------------------------
2. Terraform workflow (interviewer-style)
	Write infrastructure code in Terraform files
	Store code in version control (Git)
	Initialize Terraform
	Create and review execution plan
	Get approvals (for prod)
  Apply changes
	Terraform updates state
	Monitor and iterate
---------------------------------------------------------------------------------------------------------------------------------------------------
3. Terraform init prepares the environment(Downloads required providers (AWS, Azure, etc.) Configures backend (S3, Terraform Cloud, etc.)
Sets up state locking, plan shows the infrastructure diff, and apply reconciles actual infrastructure to the desired state while
updating the state file.
---------------------------------------------------------------------------------------------------------------------------------------------------
4. Statefile in s3 

If Terraform state stored in an S3 bucket is deleted while versioning is enabled, S3 creates a delete marker instead of permanently 
removing the file. Previous versions of the state remain intact and can be restored, allowing Terraform to continue managing the existing 
infrastructure safely.

terraform {
  backend "s3" {
    bucket         = "company-terraform-states"
    key            = "prod/app/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

IF WANT TO RESTORE FROM VERSION ENABLED

1) RESTORE VERSION
aws s3api get-object \
  --bucket company-terraform-states \
  --key prod/us-east-1/app/terraform.tfstate \
  --version-id v2 terraform.tfstate
PUSH TO S3
terraform state push terraform.tfstate
2) USING IMPORT

------------------------------------------------------
{
  "Effect": "Deny",
  "Action": "s3:DeleteObject",
  "Resource": "arn:aws:s3:::company-terraform-states/*"
}
This policy explicitly prevents deletion of any object inside the S3 bucket company-terraform-states.
----------------------------------------------------
terraform.tfstate (version-id: v1)  ← old
terraform.tfstate (version-id: v2)  ← old
terraform.tfstate (delete marker)    ← latest
----------------------------------------------------
terraform.tfstate
terraform.tfstate (version-id: 1)
terraform.tfstate (version-id: 2)
terraform.tfstate (version-id: 3)
----------------------------------------------------
{
  "Effect": "Deny",
  "Action": "s3:DeleteObject",
  "Resource": "arn:aws:s3:::company-terraform-states/*",
  "Condition": {
    "StringNotEquals": {
      "aws:PrincipalArn": "arn:aws:iam::123456789012:role/terraform-ci-role"
    }
  }
}
Apply the DENY unless the request comes from this specific IAM role
Yes, all infrastructure changes can be enforced to occur only via Terraform and CI/CD by restricting human 
IAM permissions to read-only, granting write permissions exclusively to a dedicated Terraform CI role, and 
enforcing this using explicit deny policies or AWS Organizations Service Control Policies. This ensures Terraform via CI/CD is 
the sole mechanism for infrastructure changes.
-----------------------------------------------------
terraform apply -var-file="env/dev.tfvars"
-----------------------------------------------------
ORDER OF PRECEDENCE

CLI -var
  ↓
CLI -var-file
  ↓
*.auto.tfvars
  ↓
terraform.tfvars
  ↓
TF_VAR_*
  ↓
variable defaults
-------------------------------------------------
terraform apply \
  -var-file=env/prod.tfvars \
  -var="image_tag=${BUILD_NUMBER}"
---
terraform apply -var="instance_type=t3.nano"
---
Terraform resolves variable values based on precedence, where command-line variables take highest priority, followed by variable files, 
auto-loaded tfvars, environment variables, and finally default values defined in the variable block.
---
Terraform does not “inject” variables unless you reference them.
---
Values defined directly inside a Terraform resource block are hard-coded and take absolute precedence. They cannot be overridden by
tfvars, environment variables, or CLI arguments unless the value is sourced from a variables.
----------------------------------------------------------------------------------------------------------------------------------------------

pipeline {
  agent any

  parameters {
    choice(
      name: 'ENV',
      choices: ['dev', 'stage', 'prod'],
      description: 'Select environment'
    )
  }

  environment {
    TF_IN_AUTOMATION = "true"
  }

  stages {

    stage('Checkout Code') {
      steps {
        checkout scm
      }
    }

    stage('Terraform Format') {
      steps {
        sh '''
          terraform fmt -check -recursive
        '''
      }
    }

    stage('Terraform Init') {
      steps {
        dir("envs/${ENV}") {
          sh '''
            terraform init -input=false
          '''
        }
      }
    }

    stage('Terraform Validate') {
      steps {
        dir("envs/${ENV}") {
          sh '''
            terraform validate
          '''
        }
      }
    }

    stage('TFLint') {
      steps {
        dir("envs/${ENV}") {
          sh '''
            tflint --recursive
          '''
        }
      }
    }

    stage('Checkov Security Scan') {
      steps {
        dir("envs/${ENV}") {
          sh '''
            checkov -d . --quiet
          '''
        }
      }
    }

    stage('Terraform Plan') {
      steps {
        dir("envs/${ENV}") {
          sh '''
            terraform plan -out=tfplan
          '''
        }
      }
    }

    stage('Manual Approval') {
      when {
        expression { params.ENV == 'prod' }
      }
      steps {
        input message: "Approve Terraform APPLY for PROD?"
      }
    }

    stage('Terraform Apply') {
      steps {
        dir("envs/${ENV}") {
          sh '''
            terraform apply -auto-approve tfplan
          '''
        }
      }
    }
  }

  post {
    always {
      echo "Pipeline completed for environment: ${ENV}"
    }
  }
}
--------------------------------------------------------
terraform.tfstate.d
This directory is used ONLY when Terraform workspaces are enabled.
---------------------------------------------------------
terraform/
├── Jenkinsfile
│
├── envs/
│   ├── dev/
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   ├── outputs.tf
│   │   └── versions.tf
│   │
│   ├── stage/
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   ├── outputs.tf
│   │   └── versions.tf
│   │
│   └── prod/
│       ├── backend.tf
│       ├── main.tf
│       ├── variables.tf
│       ├── terraform.tfvars
│       ├── outputs.tf
│       └── versions.tf
│
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   │
│   ├── ec2/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   │
│   ├── alb/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   │
│   ├── rds/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   │
│   └── iam/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md
│
├── global/
│   ├── backend.tf
│   ├── providers.tf
│   └── versions.tf
│
├── scripts/
│   ├── init.sh
│   ├── plan.sh
│   └── apply.sh
│
├── .gitignore
└── README.md
-------------------------------------------------------
TERRAFORM IMPORT
Identify the Existing Resource
---
Write Terraform Resource Block (Manual)
resource "aws_instance" "existing_ec2" {
  # Attributes will be filled later
}
The resource block must exist before import.
---
Initialize Terraform
terraform init
Initializes backend
Downloads providers
Prepares state
---
Run Terraform Import
terraform import aws_instance.existing_ec2 i-0abc12345def67890
What happens internally:
Terraform calls AWS API
Reads EC2 details
Writes them into the state file
NO changes to AWS
---
Verify State
terraform state show aws_instance.existing_ec2
---
Update Terraform Code to Match Reality (CRITICAL STEP)
---
Run Terraform Plan
---
terraform apply(OPTIONAL)
---
Terraform does not create the state file during terraform init. The state file is created only when Terraform writes state, 
such as during terraform apply or terraform import. Init only configures the backend and prepares Terraform to manage state.
---
terraform.tfstate.lock.info is a temporary local file created by Terraform during state-locking operations. It stores metadata about
the current lock, such as who holds it and what operation is running, while the actual lock is enforced remotely, for example in DynamoDB.
It is created ONLY when Terraform is actually locking the state, and that depends on whether the backend supports locking (like DynamoDB).
------------------------------------------------------------------------------------------------------------------------------------------
TERRAFORM TAINT/REPLACE - Taint = force rebuild
terraform taint marks a specific resource as “damaged” so Terraform will destroy and recreate it on the next apply.
----
Terraform taint marks a resource in the state as needing replacement, forcing Terraform to destroy and recreate it on the next apply. 
It is commonly used to recover from corrupted or misbehaving resources without changing configuration.
---
| #  | Scenario          | Problem                         | Why Normal `apply` Won’t Fix    | Why `taint` Works                     | Example Resource                  |
| -- | ----------------- | ------------------------------- | ------------------------------- | ------------------------------------- | --------------------------------- |
| 1  | Corrupted VM      | Instance running but OS broken  | Terraform sees no config change | Forces destroy + recreate             | `aws_instance`                    |
| 2  | User-data failed  | Bootstrap script didn’t run     | User-data runs only on create   | Recreates instance → user-data reruns | `aws_instance`                    |
| 3  | Partial creation  | Apply failed halfway            | State says resource exists      | Rebuilds clean resource               | `aws_db_instance`                 |
| 4  | Provider bug      | Resource created incorrectly    | Terraform thinks it’s correct   | Forces fresh creation                 | Any resource                      |
| 5  | Stuck resource    | Resource stuck in bad AWS state | Drift not detectable            | Full replacement fixes                | `aws_lb`, `aws_eks_node_group`    |
| 6  | Bad AMI           | Wrong AMI used                  | No diff in code                 | Forces new instance                   | `aws_instance`                    |
| 7  | Immutable infra   | Immutable design                | Updates not allowed             | Replace instead of modify             | EC2 / ASG                         |
| 8  | Config mismatch   | Manual hotfix broke internals   | Drift not visible in plan       | Replace restores expected state       | EC2 / ALB                         |
| 9  | Broken networking | ENI or attachment corrupted     | Terraform can’t detect          | Recreate resource                     | `aws_instance`, `aws_nat_gateway` |
| 10 | Secrets baked     | Credentials compromised         | Cannot rotate in-place          | New resource with new secrets         | VM / ECS Task                     |
Real-Time Use Case #3: Load Balancer in Broken State
Scenario
ALB exists
Misconfigured listeners
Terraform doesn’t detect drift
  -Solution
terraform taint aws_lb.app
terraform apply
Forces full recreation.
---
Without modifying the state beforehand” means Terraform does not write any marker or flag into the state file when requesting a 
replace. The replacement instruction exists only for that execution and the state is updated normally after the apply completes.
---
Taint permanently modifies the state before apply, while -replace is a one-time, runtime instruction that does not alter state beforehand.
---
taint
Writes to state immediately
Marks resource as tainted
Any future apply will destroy it
State remains altered if apply never runs

-replace
State unchanged
Replacement exists only in memory
Resource replaced during apply
State updated normally afterward
terrafrom taint aws_instance.web
terraform plan -replace="aws_instance.web"
terraform apply -replace="aws_instance.web"

-----------------------------------------------
TERRAFORM REFRESH
PROVISONERS
NULL RESOURCES
LIFECYCLE POLICIES
DATA SOURCES
drift detection strategies
terraform best practice
how to manage secrets

