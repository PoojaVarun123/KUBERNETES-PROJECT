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
Taint and replace in Terraform are used to force the recreation of resources.
Taint marks a resource as damaged so Terraform destroys and recreates it on the next apply.
The replace option is the newer and recommended way to achieve the same behavior.
Both are used when a resource is unhealthy or misconfigured but Terraform doesn’t detect a change.
They do not change the configuration, only the resource lifecycle.
Replace is preferred because it is safer, more explicit, and integrated into the plan.”
---
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
Terraform refresh is used to synchronize the Terraform state file with the actual infrastructure without making any changes.
It checks real resources and updates the state to reflect their current values.
terraform refresh was used earlier as a separate command, but now the recommended approach is terraform apply -refresh-only.
Refresh-only updates the state file but does not create, modify, or destroy any resources.
It is mainly used when infrastructure was changed outside Terraform.
This ensures Terraform state remains accurate before planning or applying changes.”
Terraform refresh updates only the state to reflect real infrastructure and never modifies configuration code. Any differences between 
refreshed state and configuration are shown during plan and must be resolved by changing the code or applying Terraform.
---
terraform apply -refresh-only

-----------------------------------------------
PROVISONERS
Terraform provisioners execute scripts after resource creation but are discouraged because they are not idempotent, break Terraform’s 
declarative model, depend on connectivity, and are hard to manage in CI/CD. They should be used only as a last resort.
---
Provisioners are used to execute scripts or commands on a resource after it is created (or before it is destroyed).
---
resource "aws_instance" "web" {
  ami           = "ami-0abc123"
  instance_type = "t3.micro"

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y nginx",
      "sudo systemctl start nginx"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("key.pem")
    host        = self.public_ip
  }
}
---
provisioner "file" {
  source      = "app.conf"
  destination = "/etc/app.conf"
}
---
resource "aws_s3_bucket" "bucket" {
  bucket = "example-bucket"

  provisioner "local-exec" {
    command = "echo Bucket created"
  }
}
---
NULL RESOURCES
null_resource in Terraform is a special resource that does not create any real infrastructure.
It is mainly used to execute scripts or actions using provisioners when certain conditions change.
null_resource relies on triggers to decide when it should be recreated and run again.
In real projects, it has been used for tasks like running database migrations, registering services with external systems, or restarting 
applications after configuration changes.
However, it is not preferred because it breaks Terraform’s declarative model and causes unpredictable behavior.
Modern best practices recommend moving these actions to CI/CD pipelines, cloud-init, or native Terraform resources instead.
---------------------------------
LIFECYCLE POLICIES
Lifecycle policies in Terraform control how resources are created, updated, and destroyed.
They allow us to prevent accidental deletion, manage replacement order, and ignore specific attribute changes.
Common lifecycle rules include prevent_destroy, create_before_destroy, and ignore_changes.
They are mainly used to protect critical resources, avoid downtime during updates, and handle externally managed changes.
Lifecycle policies help make infrastructure safer and more predictable in production environments.”
---
prevent_destroy
Use Case (Real-Time)
Production databases
S3 buckets with critical data
IAM roles
resource "aws_db_instance" "prod_db" {
  identifier = "prod-db"

  lifecycle {
    prevent_destroy = true
  }
}
---
create_before_destroy
Use Case (Real-Time)
Load balancers
Auto Scaling Launch Templates
Application servers
resource "aws_instance" "app" {
  ami           = "ami-xxxx"
  instance_type = "t3.micro"

  lifecycle {
    create_before_destroy = true
  }
}
---
ignore_changes
Use Case (Real-Time)
Tags modified manually
Auto-scaled attributes
AMI updated outside Terraform
resource "aws_instance" "web" {
  ami           = "ami-xxxx"
  instance_type = "t3.micro"

  lifecycle {
    ignore_changes = [
      tags,
      user_data
    ]
  }
}
--------------------------------------------------
DATA SOURCES

drift detection strategies
terraform best practice
how to manage secrets
meta arguemnts
count and for each
variables and other functions

