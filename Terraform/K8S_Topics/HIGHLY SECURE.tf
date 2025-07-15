====================================================================================================
                                     HIGHLY SECURE EKS
====================================================================================================
Securing an Amazon EKS (Elastic Kubernetes Service) cluster involves securing:
  -The EKS control plane (managed by AWS)
  -The worker nodes and networking (your responsibility)
  -The pods, data, and access to the cluster
====================================================================================================
1. Control Access to the Cluster (Authentication & Authorization)
 A. Use IAM Roles for EKS Access
 Grant cluster access only via IAM roles using the aws-auth ConfigMap.

Example: Add a user or role to aws-auth:
# aws-auth ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: arn:aws:iam::<account-id>: role/EKSAdminRole
      username: eks-admin
      groups:
        - system: masters
❗ Avoid giving system : masters to everyone!
--------------------------------------------------------------------------------------------------
B. Use RBAC to Restrict Access
Example: Allow dev-user to view pods only:

kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: dev
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: read-pods-binding
  namespace: dev
subjects:
- kind: User
  name: dev-user
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
====================================================================================================
2. Secure Network Traffic (Ingress, Egress, Pod Communication)

A. Use VPC CNI + Security Groups for Pods (SGP)
Assign IAM roles and security groups per pod using IRSA + SGP.
--------------------------------------------------------------------------------------------------
B. Use Kubernetes Network Policies
Securing an EKS cluster involves securing:
  -Access (IAM + RBAC)
  -Pods (Pod Security + Tolerations)
  -Networking (NetworkPolicies)
  -Secrets (Encrypted + External Store)
  -Add-ons & Updates
  -Audit & Monitoring

===================================================================================================
1. Secure Cluster Access with IAM + RBAC
EKS uses IAM for authentication and RBAC for authorization.

A. Restrict EKS Admin Role in the aws-auth ConfigMap

# aws-auth ConfigMap (apply with kubectl edit)
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: arn:aws:iam::123456789012:role/EKSAdminRole
      username: eks-admin
      groups:
        - system:masters
Only trusted roles should have system:masters!

B. Create RBAC Role to Limit Namespace Access
yaml
Copy
Edit
# Allow user to only list pods in dev namespace
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: dev
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: bind-pod-reader
  namespace: dev
subjects:
- kind: User
  name: dev-user
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
--------------------------------------------------------------------------------------------------
2. Enforce Pod Security Standards (PSA)
Use Kubernetes’ built-in PodSecurityAdmission to restrict risky pod configurations.
Namespace labeled with restricted policy:

apiVersion: v1
kind: Namespace
metadata:
  name: prod
  labels:
    pod-security.kubernetes.io/enforce: restricted
--------------------------------------------------------------------------------------------------
3. Apply NetworkPolicies to Limit Pod Traffic
EKS supports CNI plugins like Calico that enforce NetworkPolicies.
Block external traffic, allow only internal namespace:

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-only-internal
  namespace: app
spec:
  podSelector: {}  # Applies to all pods
  ingress:
    - from:
        - podSelector: {}  # Only from within the namespace
  policyTypes:
    - Ingress
Requires Calico or similar CNI that supports NetworkPolicy.
--------------------------------------------------------------------------------------------------
4. Encrypt & Inject Secrets Securely

A. Use External Secrets from AWS Secrets Manager
Enable IRSA (IAM Role for Service Account)
Install Secrets Store CSI driver
Use this YAML to mount secret:

apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: aws-secrets
  namespace: default
spec:
  provider: aws
  parameters:
    objects: |
      - objectName: "my-secret"
        objectType: "secretsmanager"

apiVersion: v1
kind: Pod
metadata:
  name: app-using-secret
spec:
  serviceAccountName: my-app-sa
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: secrets-store-inline
      mountPath: "/mnt/secrets"
  volumes:
  - name: secrets-store-inline
    csi:
      driver: secrets-store.csi.k8s.io
      readOnly: true
      volumeAttributes:
        secretProviderClass: "aws-secrets"
--------------------------------------------------------------------------------------------------
5. Secure Add-ons (CoreDNS, kube-proxy, etc.)
Keep all EKS Managed Add-ons (CoreDNS, kube-proxy, VPC CNI) up to date.

aws eks update-addon \
  --cluster-name my-eks \
  --addon-name coredns \
  --addon-version v1.11.1-eksbuild.2
--------------------------------------------------------------------------------------------------
6. Enable Audit Logs
Enable control plane logging from AWS Console or CLI:

aws eks update-cluster-config \
  --region us-east-1 \
  --name my-eks \
  --logging '{"clusterLogging":[{"types":["audit","authenticator","controllerManager"],"enabled":true}]}'
--------------------------------------------------------------------------------------------------
7. Restrict Node Access (Hardening Worker Nodes)
Launch nodes in private subnets only
Use Security Groups for Pods (SGP)
Disable SSH access
Enable nodeRestriction admission plugin
--------------------------------------------------------------------------------------------------
8. Enable Container Runtime Security
Use non-root containers
Add security context:
securityContext:
  runAsUser: 1000
  runAsNonRoot: true
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false

Use tools like:
-OPA Gatekeeper
-Falco for runtime monitoring
--------------------------------------------------------------------------------------------------
Summary:
Security Layer	-Tools / Example	YAML Included?
Access Control -	IAM + RBAC	✅
Pod Security	- PSA (restricted)	✅
Networking	- NetworkPolicy + Calico	✅
Secret Management	- IRSA + CSI + SecretsMgr	✅
Node Hardening	- Private + No SSH	✅ (partial)
Add-on Patching - 	aws cli update-addon	✅
Audit Logging	- CloudTrail + EKS config	✅
