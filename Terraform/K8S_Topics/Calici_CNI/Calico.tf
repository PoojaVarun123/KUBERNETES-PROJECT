
Calico Installation on EKS with IRSA (IAM Roles for Service Accounts)

✅ This is useful when you want to run Calico with AWS-specific permissions (e.g., for Calico Egress Gateway or using Calico Cloud).

Step 1: Enable OIDC on EKS (if not already):
eksctl utils associate-iam-oidc-provider --cluster <cluster-name> --approve

Step 2: Create an IAM Policy (if required):
Example: For Calico egress access (optional)

aws iam create-policy \
  --policy-name CalicoEgressPolicy \
  --policy-document file://calico-iam-policy.json

Step 3: Create an IAM Role + ServiceAccount:
eksctl create iamserviceaccount \
  --cluster <cluster-name> \
  --namespace kube-system \
  --name calico-sa \
  --attach-policy-arn arn:aws:iam::<account-id>:policy/CalicoEgressPolicy \
  --approve

---
🚀 2️⃣ Calico Installation Using Helm on EKS
helm repo add projectcalico https://projectcalico.docs.tigera.io/charts
helm repo update
helm install calico projectcalico/tigera-operator --namespace tigera-operator --create-namespace

👉 This installs:
Calico networking
Calico NetworkPolicy support
Calico Operator (for managing CRDs)
-------------------------------------------------------------------------------------------------

🚀 3️⃣ Enabling Strict Network Policy Mode (Zero Trust Networking)
✅ By default, Kubernetes allows all traffic unless blocked by a policy.

Step 1: Apply a Default Deny All Policy to every namespace:
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: default
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress

✅ This blocks:
All incoming and outgoing traffic until explicitly allowed.

Step 2: Create Allow Policies for required traffic:
Example: Allow traffic to pod labels app: frontend

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: frontend
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: backend

Use Case IRSA Needed?

Calico pods accessing AWS APIs (e.g., for Egress) ✅ Yes
Calico-managed external traffic using AWS NAT or EIPs ✅ Yes
Calico pod using AWS Secret Manager or S3 ✅ Yes
---------------------------------------------------------------------------------------------------------
🚨 By Default:
Kubernetes has the concept of NetworkPolicies (it’s part of the Kubernetes API from networking.k8s.io/v1)

BUT ❗ Kubernetes itself does not enforce these policies.
---
Feature Does Kubernetes Have It?
NetworkPolicy API/Objects ✅ Yes (built-in resource: kind: NetworkPolicy)
Enforcement of those policies ❌ No (depends on CNI plugin)
---
✅ What this means practically:
1️⃣ You can create a NetworkPolicy in any Kubernetes cluster:
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: example
  namespace: default
spec:
  podSelector: {}
  policyTypes:
  - Ingress

2️⃣ But if your CNI (Container Network Interface) does not support or enforce NetworkPolicies:
👉 The policy will exist but do nothing.
---
🔍 Default CNI Behavior in EKS:
CNI Plugin Supports NetworkPolicy?
AWS VPC CNI (default in EKS) ❌ No native support
Calico ✅ Yes
Cilium ✅ Yes
Weave Net ✅ Yes
Flannel ❌ No

Kubernetes defines NetworkPolicies = Yes
Kubernetes enforces NetworkPolicies = No (needs a CNI)

👉 That’s why you need something like:
Calico → open-source, easy
Cilium → eBPF-based, advanced
AWS Network Firewall (expensive, heavy-handed)
---
✅ Real-World Production Summary:
Scenario What You Need
Just running pods (no restrictions) AWS VPC CNI (default) is fine
Need pod-to-pod security & policies Install Calico or Cilium
Strict Zero Trust + egress control Calico or Cilium mandatory

