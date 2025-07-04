SECRET MANAGER 
-Store cred in AWS 
-Install Secrets Store CSI Driver in Kubernetes
-IRSA attach policy
-Create a Kubernetes ServiceAccount with IRSA
-SecretProviderClass
-Create a Kubernetes Deployment to Use the Secret

📌 Scenario:
✅ You have an application running on EKS (Elastic Kubernetes Service).
✅ You want to store sensitive data like database credentials in AWS Secrets Manager instead of Kubernetes Secrets for better security.
✅ You will access these secrets in Kubernetes Pods using the Secrets Store CSI Driver.
=======================================================================================================================================
Step 1: Store Secrets in AWS Secrets Manager
=======================================================================================================================================
1. Terraform Files to Create Secrets Securely

➤ variables.tf
variable "db_username" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}
----------------------------------------------------------------------------------------------------
➤ provider.tf

provider "aws" {
  region = var.aws_region
}
----------------------------------------------------------------------------------------------------
➤ secrets.tf

resource "aws_secretsmanager_secret" "db_secret" {
  name        = "prod/db-credentials"
  description = "Production DB credentials"
}

resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id = aws_secretsmanager_secret.db_secret.id

  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}
----------------------------------------------------------------------------------------------------
➤ How to Provide Secrets Securely:
✅ Use Environment Variables:

export TF_VAR_db_username=adminuser
export TF_VAR_db_password=SuperSecret123
terraform init
terraform apply
✅ This ensures that secrets never appear in the code or tfstate in plaintext.

=======================================================================================================================================
Step 2: Install Secrets Store CSI Driver in Kubernetes
=======================================================================================================================================
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/v1.4.0/deploy/rbac-secretproviderclass.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/v1.4.0/deploy/csi-secret-store.yaml
=======================================================================================================================================
Step 3: Install AWS Provider for Secrets Store CSI
=======================================================================================================================================
kubectl apply -f https://raw.githubusercontent.com/aws/secrets-store-csi-driver-provider-aws/main/deployment/aws-provider-installer.yaml
=======================================================================================================================================
Step 4: IAM Role for Service Account (IRSA) - Terraform Example
=======================================================================================================================================
provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "eks_secrets_role" {
  name = "eks-secrets-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/EXAMPLED539D4633E53DE1B71EXAMPLE"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
    }]
  })
}

resource "aws_iam_role_policy" "secrets_policy" {
  role = aws_iam_role.eks_secrets_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue"
      ]
      Resource = "arn:aws:secretsmanager:us-east-1:123456789012:secret:prod/db-credentials-*"
    }]
  })
}

✅ Note: Replace account ID, region, and OIDC provider URL as per your EKS cluster.

=======================================================================================================================================
Step 5: Create Kubernetes ServiceAccount with IRSA
=======================================================================================================================================
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-sa
  namespace: default
annotations:
  eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/eks-secrets-access-role

Apply:
kubectl apply -f serviceaccount.yaml
=======================================================================================================================================
Step 6: Create SecretProviderClass YAML
=======================================================================================================================================
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: aws-secrets
  namespace: default
spec:
  provider: aws
  parameters:
    objects: |
      - objectName: "prod/db-credentials"
        objectType: "secretsmanager"

Apply:
kubectl apply -f secretproviderclass.yaml

=======================================================================================================================================
Step 7: Create Kubernetes Deployment to Use the Secret
=======================================================================================================================================
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      serviceAccountName: app-sa
      containers:
        - name: my-container
          image: nginx
          volumeMounts:
            - name: secrets-store-inline
              mountPath: "/mnt/secrets"
              readOnly: true
      volumes:
        - name: secrets-store-inline
          csi:
            driver: secrets-store.csi.k8s.io
            readOnly: true
            volumeAttributes:
              secretProviderClass: "aws-secrets"

👉 This mounts the secret JSON file into /mnt/secrets.
=======================================================================================================================================
Step 8: Access the Secrets inside the Container
=======================================================================================================================================
Inside the running pod:
kubectl exec -it <pod-name> -- cat /mnt/secrets/prod--db-credentials
The file content will be:
{"username":"adminuser","password":"SuperSecret123"}

---
✅ Why this Approach?
Feature Secrets Store CSI + AWS Secrets Manager
Centralized Secret Mgmt ✅ Yes (AWS Secrets Manager)
Automatic Rotation ✅ Yes
IAM-based Access ✅ Yes
No Secret in etcd ✅ Yes

