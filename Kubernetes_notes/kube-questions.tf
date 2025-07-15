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


