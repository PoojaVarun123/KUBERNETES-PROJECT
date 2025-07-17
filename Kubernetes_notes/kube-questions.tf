=============================================================================================================
                                          KUBERNETES QUESTIONS
=============================================================================================================
1) what is kubernetes?
-------------------------------------------------------------------------------------------------------------
2) Kubernetes architecture?
   -master: worker
   -control: data
-------------------------------------------------------------------------------------------------------------
3) Pod
   -Smallest unit of deployment in Kubernetes and a wrapper of a container
   Features:
      -Runs one or more containers.
      -Shared network/IP and storage among containers in the pod.
      -Short-lived: Pods are ephemeral; if a pod dies, it’s not automatically recreated (that’s why we use higher-level controllers).
      -Designed for tightly coupled containers (e.g., a main app and a sidecar).
-------------------------------------------------------------------------------------------------------------
4) Deployment
> Manages ReplicaSets and provides declarative updates for Pods
   Features:
      -Ensures a specific number of pod replicas are always running.
      -Supports rolling updates and rollbacks.
      -Automatically replaces failed pods.
      -Uses ReplicaSet internally.
      -Can scale up/down easily.
Declarative: define the desired state in a YAML, and Kubernetes maintains it.
-------------------------------------------------------------------------------------------------------------
5) ReplicaSet
-Ensures a specified number of identical pods are running
   Features:
      -Automatically maintains the number of replicas.
      -Replaces pods if they crash or are deleted.
      -Used indirectly through Deployments (rarely created manually).
      -Matches pods using label selectors.
-------------------------------------------------------------------------------------------------------------
6) StatefulSet
-Used to deploy stateful, ordered, and unique identity-based applications
Features:
      -Provides each pod a stable hostname and persistent storage.
      -Pods have ordered startup and termination.
      -Pods are not interchangeable (e.g., pod-0, pod-1, etc.).
      -Ideal for databases and distributed systems (e.g., Cassandra, Kafka).
      -Works with PersistentVolumeClaim templates.
-------------------------------------------------------------------------------------------------------------
7) Service
-Exposes pods as a network service inside (or outside) the cluster
✅ Features:
Provides a stable IP and DNS name regardless of pod restarts.
Supports load balancing across matching pods.
Can be exposed:
   -ClusterIP (internal)
   -NodePort (external on node IP)
   -LoadBalancer (via cloud load balancer)
Works with label selectors to find matching pods.
-------------------------------------------------------------------------------------------------------------
8) Ingress
-Manages external HTTP/HTTPS access to services inside the cluster
✅ Features:
-Acts as a reverse proxy (Layer 7 load balancer).
-Routes traffic based on hostnames or URL paths.
-Supports TLS (HTTPS) termination.
-Requires an Ingress Controller (e.g., NGINX, AWS ALB).
Centralized entry point for multiple services.

Object Key Features:
Pod > Runs containers; shares network & storage; basic unit
Deployment > Manages ReplicaSets; rolling updates; self-healing; scaling
ReplicaSet > Maintains N identical pods; auto-replaces failed pods
StatefulSet > Unique pod identity; persistent storage; ordered start/stop
Service > Stable IP/DNS; load balances across pods; internal/external access
Ingress  > Routes HTTP(S) traffic; path- or host-based; TLS support; needs controller
-------------------------------------------------------------------------------------------------------------
9) What is a label/selector?
  -A label is a key-value pair that you attach to Kubernetes objects (like Pods, Nodes, Services, etc.) to organize and identify them.
  -A selector is used to find and match Kubernetes objects based on their labels.
  -For example, a Service uses a selector to send traffic only to the pods with matching labels.
-------------------------------------------------------------------------------------------------------------
10) Why is service important?
-------------------------------------------------------------------------------------------------------------
11) Sidecar Container
   -A sidecar container is a container that runs alongside the main application container in the same Pod and provides supporting features.
      -Features:
         -Runs in parallel with the main app
         -Shares network & storage volumes
         -Used for logging, monitoring, proxying, etc.
               Example: Fluent Bit as a sidecar to forward logs to a logging system.
-------------------------------------------------------------------------------------------------------------
12) Init Container 
   -An init container runs before the main application container starts in a Pod, and must complete successfully.
      Features:
         -Runs sequentially (one after the other)
         -Used for setup tasks like DB checks, migrations
         -Cannot be restarted unless they fail
               Example: Wait for the database to become ready before starting the app.
-------------------------------------------------------------------------------------------------------------
13) Node Affinity 
   -Node affinity is a rule that tells Kubernetes to schedule pods onto nodes that match specific node labels.
      -Features:
         -Controls which nodes the pod can run on
         -Hard affinity (requiredDuringScheduling) = must match
         -Soft affinity (preferredDuringScheduling) = prefer to match
               Example: Schedule only on nodes labeled gpu=true.
      -Scenarios
         -GPU Workloads > Schedule ML pods only on GPU nodes (gpu=true)
         -High-memory workloads > Run database pods on memory-optimized nodes (memory=high)
         -Compliance or security zones: > Deploy sensitive apps to nodes labeled zone=secure
         -Team or project-based segregation > Run Team A’s workloads only on nodes labeled team=team-a
         -Region/zone-based control > Place pods only in a specific AZ (e.g. topology.kubernetes.io/zone=us-east-1a)
         -Staging vs Production > Label nodes as env=prod or env=stage and separate workloads
-------------------------------------------------------------------------------------------------------------
14) Pod Affinity 
   -Pod affinity tells Kubernetes to schedule a pod close to other pods with specific labels (e.g., same node or zone).
      -Features:
         -Based on pod labels
         -Defines co-location (same node or topology zone)
         -Improves performance or latency between related services
               Example: Schedule frontend pods near backend pods.
      -Scenarios:
         -Reduce latency > Place frontend and backend pods close together (same zone or node)
         -Realtime chat or game services > Co-locate chat gateway and messaging pods for low-latency comms
         -Shared caching > Place pods near Redis or Memcached instances
         -Group-related microservices > Deploy service components of the same app on the same node for performance
         -Application-specific zones > Group pods belonging to the same business function (e.g., analytics) on the same physical machine for data locality
-------------------------------------------------------------------------------------------------------------
15) Anti-Pod Affinity 
   -Anti-pod affinity ensures that a pod is not scheduled on the same node (or zone) as other pods with specific labels.
      -Features:
         -Improves high availability and fault tolerance
         -Distributes replicas across nodes or zones
               Example: Don’t schedule two replicas of the same app on the same node.
      -Scenarios:
         -Highly Available replicas > Spread replicas of a database (e.g., MongoDB) across different nodes
         -Avoid resource contention  >Prevent two high-CPU pods from landing on the same node
         -Avoid single point of failure  > Distribute workloads across zones/nodes for resilience
         -Multi-tenant isolation > Prevent pods from different teams or tenants from sharing a node
         -Load balancing of pods > Prevent too many similar apps (like workers) from clustering together
-------------------------------------------------------------------------------------------------------------
16) Taints 
   -A taint is applied to a node to prevent pods from being scheduled on it unless they tolerate the taint.
      -Features:   
         -Used to repel pods from specific nodes
         -Enforces strict placement control   
         -Taint types: NoSchedule, PreferNoSchedule, NoExecute
               Example: Taint a node for GPU workloads only.
      -Scenarios:     
         -Dedicated DB nodes > dedicated=database:NoSchedule Block non-DB pods
         -Control plane node > node-role.kubernetes.io/control-plane=:NoSchedule Protect master
         -GPU workloads > only hardware=gpu:NoSchedule Restrict general workloads
         -Spot nodes > lifecycle=spot:NoSchedule Prevent critical pods
         -Logging nodes >  monitoring=true:NoSchedule Dedicated for observability
         -Maintenance > maintenance=true: NoExecute Evict pods during upgrade
         -Team A nodes  > team=team-a:NoSchedule Tenant/workload isolation
         -Soft avoidance  > prefer=special:PreferNoSchedule Prefer but allow pods
-------------------------------------------------------------------------------------------------------------
17) Tolerations 
   -A toleration is applied to pods to allow them to be scheduled on nodes with matching taints.
      -Features:
         -Works together with taints
         -Allows pod to run on restricted nodes
         -Does not force scheduling — only permits
               Example: A pod that tolerates dedicated=gpu: NoSchedule can run on a GPU node
-------------------------------------------------------------------------------------------------------------
18) Persistent Volume (PV) 
   -A Persistent Volume (PV) is a piece of cluster-managed storage provisioned manually or dynamically.
      -Features:
            -Exists independently of pods
            -Defined and managed by cluster admins
            -Backed by physical storage (EBS, NFS, etc.)
               Example: A 100Gi EBS volume for storing database files.
-------------------------------------------------------------------------------------------------------------
19) Persistent Volume Claim (PVC) 
   -A Persistent Volume Claim (PVC) is a request for storage by a user or pod.
      -Features:
         -Automatically binds to a matching PV
         -Specifies size and access mode
         -Allows pods to persist data beyond pod restarts
               Example: App requests 10Gi ReadWriteOnce storage.
-------------------------------------------------------------------------------------------------------------
20). Deployment Strategy 
   -A deployment strategy defines how pods are updated when a new version of the application is deployed.
      -Types:
         -RollingUpdate (default): updates pods gradually (zero downtime)
         -Recreate: deletes old pods first, then creates new ones (downtime)
-------------------------------------------------------------------------------------------------------------
21) maxUnavailable 
   -Controls the maximum number of pods that can be unavailable during a rolling update.
      -Features:
         -Can be a number or a percentage
         -Balances availability during updates
            Example: maxUnavailable: 1 means at most 1 pod can be down.
-------------------------------------------------------------------------------------------------------------
22) maxSurge
   -maxSurge controls the maximum number of extra pods that can be created temporarily during a rolling update.
      -Features:
         -Helps in faster updates
         -Supports zero-downtime deployments
         -Can also be a number or percentage
               Example: maxSurge: 2 means 2 extra new pods can be added during the update.

Sidecar Container > Provides supporting features (e.g., logging, proxy)
Init Container > Runs setup tasks before the app starts
Node Affinity > Schedule pod to specific nodes
Pod Affinity > Schedule a pod close to other pods
Anti-Pod Affinity > Keep pods apart from each other
Taints > Prevent scheduling on a node
Tolerations > Allow scheduling on tainted nodes
-------------------------------------------------------------------------------------------------------------
23) Pod Disruption Budget
    -A Pod Disruption Budget (PDB) in Kubernetes is a policy that limits the number of pods that can be voluntarily disrupted (evicted) at a time.
    -It ensures that a minimum number or percentage of pods remain available and running during operations like:
        -Node drain (e.g., for upgrades)
        -Cluster autoscaler removing nodes
        -Voluntary eviction by an admin or automation
    -Involuntary disruptions (like node crashes or hardware failures) are not governed by PDB.

        Common Use Cases:
            -Node maintenance or drain - Prevents all pods from being evicted at once, ensuring service stays up.
            -Cluster autoscaler scale-down - Ensures critical apps aren't removed during optimization.
            -Rolling updates - Maintains high availability by keeping a minimum number of pods running.
            -High-availability apps - Guarantees a baseline service level during disruptions
-------------------------------------------------------------------------------------------------------------
24) Custom Resource Definition
    -A Custom Resource Definition (CRD) is a way to extend Kubernetes by adding your own custom resource types.
    -It lets you define new objects (like MyApp, Database, BackupJob, etc.) that behave like built-in Kubernetes resources (Pod, Deployment, etc.).
    -Once a CRD is created, Kubernetes understands your new resource and you can use it with kubectl, YAML files, and APIs — just like native resources.
  
             Tool - Operator CRD Example - Purpose
            -Cert-Manager - Certificate - Manage TLS certs automatically
            -Prometheus Operator - ServiceMonitor - Monitor services for metrics
            -Elastic Operator - Elasticsearch - Manage Elasticsearch clusters
            -Kafka Operator - KafkaCluster - Automate Kafka deployments
            -ArgoCD - Application  - Define and manage GitOps apps

-------------------------------------------------------------------------------------------------------------
25) Horizontal Pod Autoscaling
    -HPA automatically scales the number of pod replicas up or down based on metrics like CPU, memory, or custom metrics (e.g., request rate).
    Importance:
          -Ensures your app handles increased load by adding pods.
          -Reduces pods when demand drops to optimize resource usage.
          -Maintains application performance and availability.
          -Avoids manual intervention for scaling pods.
    Use Cases:
          -Web servers, APIs, or microservices with variable traffic.
          -E-commerce sites during peak hours (scale from 5 to 20 pods).
          -CI/CD jobs that run in parallel and need dynamic scaling.


🧠 2. VPA – Vertical Pod Autoscaler

✅ **Definition:




---

🧱 3. CA – Cluster Autoscaler

✅ **Definition:


---

✅ Summary Table

Feature > HPA > VPA > CA
Definition > Scales number of pods > Adjusts CPU/memory per pod Scales number of nodes
Importance > Handles traffic spikes >  Prevents under/over-resourcing Scales infrastructure
Use Case >  Web/API services Stateful apps, batch jobs Cloud clusters, bursting workloads



---

Let me know if you want:

✅ YAML examples for each one

🗺 A diagram showing how all 3 interact

📦 Setup guide for HPA + VPA + CA in one cluster
-------------------------------------------------------------------------------------------------------------
26) Cluster Autoscaling
    -CA (Cluster Autoscaler)** automatically adds or removes nodes in a Kubernetes cluster depending on:
        Whether pods are pending due to a lack of resources.
        Whether nodes are underutilized and can be safely removed.
    Importance:
        -Ensures the cluster has enough capacity for all pods.
        -Removes idle nodes to reduce cloud costs.
        -Complements HPA and VPA by scaling the infrastructure layer.
        -Keeps the cluster efficient and responsive to dynamic workloads.
    Use Cases:
        -Cloud-native apps running in AWS EKS, GCP GKE, or Azure AKS.
        -Clusters using HPA or Jobs/CronJobs that cause bursts in demand.
        -Clusters that must auto-scale up during peak hours and down afterward.
-------------------------------------------------------------------------------------------------------------
27) Vertical Pod Autoscaling
    -VPA automatically adjusts the CPU and memory requests/limits of pods based on their real usage over time.
    Importance:
        -Helps prevent OOMKilled pods due to low memory limits.
        -Avoids resource wastage caused by over-allocating CPU/memory.
        -Right-sizes applications for performance and cost-efficiency.
        -Makes resource management easier and data-driven.
    Use Cases:
        -Stateful applications like databases (PostgreSQL, MongoDB).
        -Legacy apps that cannot scale horizontally.
        -Batch jobs or data-processing apps with fixed replica count.
-------------------------------------------------------------------------------------------------------------
28) Resource Limit
    -Resource Limits define the maximum amount of CPU and memory a container is allowed to use.
        Purpose:
            -Prevents a container from using too much CPU or memory.
            -Ensures fair usage in a shared cluster.
            -If memory exceeds the limit → the pod is OOMKilled.
            -If CPU exceeds the limit → the pod is throttled (slowed down).
    -Resource Limit > Maximum CPU/Memory allowed for a container. Prevents a container from overusing shared resources
---
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
This means: the pod needs at least 256Mi memory and 250m CPU to run, and it can use up to 512Mi memory and 500m CPU.
-------------------------------------------------------------------------------------------------------------
29) Resource Request
    -Resource Requests define the minimum amount of CPU and memory a container needs to run properly.
        -Purpose:
            -Tells the Kubernetes scheduler how much resource the pod needs.
            -Helps Kubernetes find the right node that has enough resources.
            -Guarantees that the requested amount will always be available for the pod.
    -Resource Request - Minimum CPU/Memory needed by a container Scheduler ensures pod is placed on a node with enough resources
-------------------------------------------------------------------------------------------------------------
30) Namespaces
    -A namespace is a logical partition within a Kubernetes cluster that helps separate and organize resources.
    Purpose:
        -Used to organize resources (pods, services, secrets, etc.)
        -Helps manage multi-environment setups like dev, test, prod
        -Supports access control (RBAC) and resource quotas
        -Prevents name conflicts (e.g., nginx can exist in multiple namespaces)
   -Namespace Logical partition in a cluster Organize, isolate, and manage workloads securely
-------------------------------------------------------------------------------------------------------------
31) Network policy
-------------------------------------------------------------------------------------------------------------
32) Startup Probe
-------------------------------------------------------------------------------------------------------------
33) Readiness Probe
-------------------------------------------------------------------------------------------------------------
34) Livliness Probe
-------------------------------------------------------------------------------------------------------------
35) ConfigMap 
-------------------------------------------------------------------------------------------------------------
36) Secrets
-------------------------------------------------------------------------------------------------------------
37) Rolling update
-------------------------------------------------------------------------------------------------------------
38) Blue and Green
-------------------------------------------------------------------------------------------------------------
39) Canary
-------------------------------------------------------------------------------------------------------------
40) Recreate
-------------------------------------------------------------------------------------------------------------
41) Pod Identity Association
-------------------------------------------------------------------------------------------------------------
42) Istio-Service Mesh > Purpose > How it works
-------------------------------------------------------------------------------------------------------------
43) Calico-Network Plugin
-------------------------------------------------------------------------------------------------------------
44) Pod Security Policy
-------------------------------------------------------------------------------------------------------------
45) Network Policy
-------------------------------------------------------------------------------------------------------------
46) RBAC
-------------------------------------------------------------------------------------------------------------
47) Role Binding
-------------------------------------------------------------------------------------------------------------
48) Cluster Binding
-------------------------------------------------------------------------------------------------------------
49) Service Account
-------------------------------------------------------------------------------------------------------------
50) Kube Config
-------------------------------------------------------------------------------------------------------------
51) Topology
-------------------------------------------------------------------------------------------------------------
52) Annotations
-------------------------------------------------------------------------------------------------------------
53) Kubernetes Federation
-------------------------------------------------------------------------------------------------------------
54) Multi-Cluster Management Solutions: Rancher or Anthos
-------------------------------------------------------------------------------------------------------------
55)  Multi Tenancy
-------------------------------------------------------------------------------------------------------------
56) API
-------------------------------------------------------------------------------------------------------------
57) Kubernetes Operators
-------------------------------------------------------------------------------------------------------------
58) TLS termination
-------------------------------------------------------------------------------------------------------------
59) How Scaling is Managed for Statefulset
-------------------------------------------------------------------------------------------------------------
60) OIDC
-------------------------------------------------------------------------------------------------------------
61) How to upgrade worker nodes
-------------------------------------------------------------------------------------------------------------

diff between logs and describe
Zaegar/Zepkins
Velero
etcd snapshotting



