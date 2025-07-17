============================================================================================================
                                       A ServiceAccount (SA)
============================================================================================================
A ServiceAccount (SA) in Kubernetes is an identity for processes running in a Pod. 
It provides access control to the Kubernetes API server and is commonly used for authentication and authorization of in-cluster workloads (like Pods).

In short, it defines “who” a Pod is when making API calls to the Kubernetes control plane.
---------------------------------------------------------------------------------------------------------------
Why is ServiceAccount important?
    Pods often need to interact with the Kubernetes API (e.g., list secrets, watch other resources).
    Kubernetes automatically assigns a default ServiceAccount to every Pod if not specified.
    Custom SAs allow least-privilege access and better security.
---------------------------------------------------------------------------------------------------------------
Default vs Custom ServiceAccount
default - Auto-assigned if none is specified
custom - Created by you and explicitly bound with specific permissions
---------------------------------------------------------------------------------------------------------------
Use Case Role of ServiceAccount
    Pod reading from Kubernetes Secrets SA needs permission to get secrets
    Pod accessing AWS S3 via IRSA SA is annotated with IAM role
    Prometheus scraping kubelet metrics SA is granted access to metrics endpoints
---------------------------------------------------------------------------------------------------------------
 Basic YAML Example:
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-sa
  namespace: default

Then associate it with a Pod:
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  serviceAccountName: my-sa
  containers:
  - name: my-container
    image: my-image
---------------------------------------------------------------------------------------------------------------
RBAC Binding for SA Example:
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-secrets
  namespace: default
subjects:
- kind: ServiceAccount
  name: my-sa
  namespace: default
roleRef:
  kind: Role
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
---------------------------------------------------------------------------------------------------------------
Summary:
Identity for Pod Allows API access to Kubernetes resources
Supports RBAC Can be bound to Roles/ClusterRoles
Works with Cloud IAM Used in IAM integration (e.g., AWS IRSA)
Enhances security Enables least-privilege access model
---------------------------------------------------------------------------------------------------------------
