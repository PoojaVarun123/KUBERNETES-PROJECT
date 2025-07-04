==================================================================================================================
KUBERNETES CLUSTER AUTOSCALING: Nodegroup with ASG + IRSA + CLUSTER AUTOSCALER(Values.yaml)
==================================================================================================================
🚀 Step 1: Prerequisites
✅ EKS Cluster already created
✅ At least one Managed Node Group (ASG)
✅ Kubernetes access configured (kubectl context set)
==================================================================================================================
Step 2: Tag the Auto Scaling Group (Required for Autoscaler Discovery)
==================================================================================================================
Go to your AWS Auto Scaling Group (created via EKS managed node group) and add these two tags:
Key Value
-k8s.io/cluster-autoscaler/enabled true
-k8s.io/cluster-autoscaler/<cluster-name> owned

👉 Example:
k8s.io/cluster-autoscaler/enabled = true
k8s.io/cluster-autoscaler/my-eks-cluster = owned

✅ These tags are mandatory for Cluster Autoscaler to discover your node group.
==================================================================================================================
Step 3: Create IAM Role for Cluster Autoscaler (Trust Role for IRSA)
==================================================================================================================
3.1 Get OIDC Provider for Your Cluster:
aws eks describe-cluster --name my-eks-cluster --query "cluster.identity.oidc.issuer" --output text

Example Output:
https://oidc.eks.us-east-1.amazonaws.com/id/EXAMPLED539D4633E53DE1B71EXAMPLE
-------------------------------------------------------------------------------------------------------------------
3.2 Create IAM Policy (autoscaler-policy.json):
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeTags",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeLaunchTemplateVersions"
      ],
      "Resource": "*"
    }
  ]
}

👉 Create the policy:
aws iam create-policy --policy-name eks-cluster-autoscaler-policy --policy-document file://autoscaler-policy.json
------------------------------------------------------------------------------------------------------------------
3.3 Create IAM Role & Trust Relationship:
Trust Policy:
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/EXAMPLED539D4633E53DE1B71EXAMPLE"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.us-east-1.amazonaws.com/id/EXAMPLED539D4633E53DE1B71EXAMPLE:sub": "system:serviceaccount:kube-system:cluster-autoscaler"
        }
      }
    }
  ]
}

Create the role:
aws iam create-role --role-name eks-cluster-autoscaler-role --assume-role-policy-document file://trust-policy.json

Attach policy to the role:
aws iam attach-role-policy --role-name eks-cluster-autoscaler-role --policy-arn arn:aws:iam::123456789012:policy/eks-cluster-autoscaler-policy
==================================================================================================================
Step 4: Create Kubernetes Service Account with IRSA
==================================================================================================================
apiVersion: v1
kind: ServiceAccount
metadata:
  name: cluster-autoscaler
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/eks-cluster-autoscaler-role

✅ Apply it:
kubectl apply -f serviceaccount-autoscaler.yaml
==================================================================================================================
Step 5: Install Cluster Autoscaler using Helm
==================================================================================================================
5.1 Add the Helm Repository:
helm repo add autoscaler https://kubernetes.github.io/autoscaler
helm repo update
------------------------------------------------------------------------------------------------------------------
5.2 Create values.yaml for Production:

awsRegion: us-east-1
autoDiscovery:
  clusterName: my-eks-cluster
cloudProvider: aws
rbac:
  serviceAccount:
    create: false
    name: cluster-autoscaler
extraArgs:
  balance-similar-node-groups: "true"
  skip-nodes-with-system-pods: "false"
  expander: least-waste
fullnameOverride: cluster-autoscaler
------------------------------------------------------------------------------------------------------------------
5.3 Install the Helm Chart:

helm install cluster-autoscaler autoscaler/cluster-autoscaler \
  --namespace kube-system \
  --values values.yaml

This will deploy the Cluster Autoscaler using the IRSA-enabled ServiceAccount you created earlier.
==================================================================================================================
Step 6: Verify the Deployment
==================================================================================================================
kubectl -n kube-system get deployment cluster-autoscaler
kubectl -n kube-system logs deployment/cluster-autoscaler

✅ You should see logs like:
I0704 10:00:00.000000       1 aws_manager.go:265] Refreshed ASG cache...
==================================================================================================================
Step 7: Test Auto Scaling
==================================================================================================================
👉 Deploy a pod requesting large CPU/memory to force scale-up.
👉 Remove pods or lower demand to observe scale-down.

✅ Summary Overview:
Step What You Did

✅ ASG Tagged Enabled node group discovery
✅ IAM Role & Policy Granted permissions to Autoscaler
✅ ServiceAccount Linked to IAM role (IRSA)
✅ Helm Deploy: Installed autoscaler in kube-system



-
