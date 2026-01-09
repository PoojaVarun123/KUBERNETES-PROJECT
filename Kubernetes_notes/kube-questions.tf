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
---
TLS stands for Transport Layer Security.
TLS is a security protocol that encrypts data sent between two systems so that it cannot be read or modified by attackers.
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
Feature > HPA > VPA > CA
Definition > Scales number of pods > Adjusts CPU/memory per pod Scales number of nodes
Importance > Handles traffic spikes >  Prevents under/over-resourcing Scales infrastructure
Use Case >  Web/API services Stateful apps, batch jobs Cloud clusters, bursting workloads
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
    StartupProbe is used to check if the application inside a container has started properly.
        Importance:
                Ensures Kubernetes waits long enough before declaring the app as failed.
                Prevents false restarts of slow-starting applications.
        Use Case:
                Apps like Spring Boot, legacy enterprise apps, or monoliths that take time to load libraries, configs, or data.
                Prevents interference from livenessProbe before the app is fully ready.
        Workflow:
                1. As soon as the container starts, startupProbe kicks in.
                2. It keeps checking until:
                      Success → livenessProbe and readinessProbe begin.
                      Failure threshold exceeded → Container is killed and restarted.
        Why It May Fail:
                The app takes longer to start than the configured timeout (failureThreshold * periodSeconds).
                The endpoint or port being probed is incorrect.
                The app crashes or is stuck during bootup (e.g., blocked waiting for a DB).
-------------------------------------------------------------------------------------------------------------
33) Readiness Probe
    ReadinessProbe checks if the application is ready to handle user traffic.
      Importance:
            Ensures that only healthy and ready pods receive traffic.
            Prevents downtime or errors caused by routing traffic to unready apps.
      Use Case:
            Apps that need to:
            Warm up internal caches.
            Connect to databases or APIs.
            Load configs before serving requests.
    Workflow:
            1. Kubernetes periodically checks the readiness of the container.
            2. If the probe:
                Succeeds → Pod is added to the Service endpoints.
                Fails → Pod is marked NotReady, and removed from the load balancer.
    Why It May Fail:
            The app isn't ready (e.g., DB not connected).
            The app is overloaded or too busy.
            Path or port in the probe is incorrect.
            Application crashed silently but didn't exit (so liveness stays green, but readiness fails).
-------------------------------------------------------------------------------------------------------------
34) Livliness Probe
    LivenessProbe checks whether the container is still alive and functioning properly.
        Importance:
              Helps Kubernetes detect and fix hanging or stuck containers.
              Ensures self-healing by restarting bad containers automatically.
        Use Case:
              Long-running services (e.g., web servers, backend APIs).
              Apps that may get stuck due to memory leaks, deadlocks, or infinite loops.
        Workflow:
              1. After the container starts (and startup probe passes), Kubernetes runs the livenessProbe periodically.
              2. If the probe:
                  Succeeds → All is good.
                  Fails repeatedly → Container is restarted.
        Why It May Fail:
                The app is stuck in a deadlock or high CPU/memory usage.
                The app is unresponsive (e.g., hung thread, DB lock).
                The HTTP endpoint doesn’t return a 2xx/3xx status.
                Wrong port or path configured in the probe.
Startup App has started Once, during startup Restart container Spring Boot app with slow start
Readiness App is ready to serve Repeatedly (periodic) Remove from service endpoint App needs DB/cache before responding
Liveness App is still running well Repeatedly (periodic) Restart container App may hang or crash silently
-------------------------------------------------------------------------------------------------------------
35) ConfigMap 
    -A ConfigMap is a Kubernetes object used to store non-sensitive configuration data (like app settings) in key-value format.
     It helps keep configuration separate from application code.
        Features:
            -Stores plain text data like environment variables, config files, command-line args.
              Can be used as:
                  Environment variables
                  Command-line args
                  Mounted files
                  Easy to update without changing the container image.
                  Supports full application flexibility across environments.

        Importance:
                  Helps make applications portable and manageable across dev, staging, and prod.
                  Avoids hardcoding values inside containers.
                  Supports 12-factor app principle of separating config from code.

        What’s Stored Inside:
                  Non-sensitive data like:
                  Application mode
                  URLs
                  Hostnames
                  Port numbers
                  Log levels
                  JSON/YAML configuration
-------------------------------------------------------------------------------------------------------------
36) Secrets
    -A Secret is a Kubernetes object used to store sensitive data such as passwords, API keys, certificates, in base64-encoded format.
        Features:
            -Stores confidential data securely.
            -Data is base64-encoded (can be encrypted at rest).
            -Can be exposed to pods as:
                -Environment variables
                -Mounted files (volumes)
            -Access can be controlled using RBAC.

      Importance:
            -Ensures security best practices by keeping sensitive data out of the image or config.
            -Reduces the risk of leaking credentials or secrets.
            -Secrets can be rotated without modifying containers.
      What’s Stored Inside:
            -Sensitive/confidential data like:
            -Database passwords
            -API tokens
            -TLS/SSL certificates
            -SSH keys
            -OAuth tokens
-------------------------------------------------------------------------------------------------------------
Feature > ConfigMap > Secret
Stores > Non-sensitive config data > Sensitive/private data
Data Format >  Plain text > Base64 encoded
Usage in Pod > Env vars, volumes, args > Env vars, volumes, imagePullSecrets
Encryption > Not encrypted > Can be encrypted (encryption at rest)
Access Control > Yes (via RBAC) > Yes (usually stricter)

Setting Stored In Example Value Reason:
APP_ENV ConfigMap production Non-sensitive environment config
LOG_LEVEL ConfigMap info Controls logging verbosity
DB_HOST ConfigMap mysql.prod.svc.cluster Database hostname
DB_USERNAME Secret admin Should be hidden from logs or users
DB_PASSWORD Secret mypassword Confidential; must be encrypted
API_KEY Secret abc123XYZ External service key
-------------------------------------------------------------------------------------------------------------
37) Rolling update
    -In Kubernetes, the Rolling Update strategy is the default and most commonly used deployment strategy for 
      updating applications with zero downtime.
    -It works by gradually replacing old Pods with new ones, instead of terminating all the existing Pods at once. 
      This ensures that the application remains available to users throughout the deployment process.
    -When a new deployment is triggered — for example, by updating the container image version — Kubernetes:
          -Terminates a few old Pods based on the maxUnavailable setting,
          -And simultaneously spins up new Pods (controlled by the maxSurge parameter).
          -Each new Pod goes through health checks like:
                -Startup Probe (if defined): to ensure the app has started correctly,
                -Liveness Probe: to verify that the app is running and responsive,
                -Readiness Probe: to confirm the app is ready to handle traffic.

    -Only after a Pod passes the readiness check, it is added to the Service and starts receiving user traffic. 
    -If the Pod fails liveness or readiness checks, Kubernetes either restarts it or withholds it from serving traffic — 
      preventing bad deployments from affecting users.
    -This strategy is ideal for production systems because it provides:
        Continuous availability,Controlled rollout speed,And easy rollback if needed using kubectl rollout undo.
    -Overall, the Rolling Update strategy ensures smooth and safe application updates with high availability."
-------------------------------------------------------------------------------------------------------------
38) Blue and Green
    -Blue-Green deployment is a strategy where I maintain two separate environments: Blue (the live environment) and Green (the new version).
    -When I want to release a new version, I deploy it entirely to the Green environment without affecting the live users. 
    -This lets me perform testing, QA, and validation in a production-like setup.
    -Once everything in Green looks good, I simply switch the traffic from Blue to Green — usually by updating a load balancer or service.
     This switch is instant and safe, and if something goes wrong, I can quickly revert by directing traffic back to the Blue environment.
    -I prefer this approach when I need zero-downtime, fast rollback, and full isolation between versions — 
     especially for critical applications where partial rollouts are risky.
-------------------------------------------------------------------------------------------------------------
39) Canary
    -Canary deployment is a strategy where I gradually roll out a new version of the application to a small percentage of users.
     Initially, only a few Pods run the new version (the canary), and a small fraction of user traffic is directed to them — say 5% or 10%.
    -I closely monitor the system’s performance, error rates, and logs during this phase. If everything goes well, 
     I incrementally increase traffic to the canary Pods until it reaches 100%.
    -If any issue is detected at any stage, I stop the rollout and route all traffic back to the stable version — 
     limiting the impact to just the small user base.
    -This strategy is very effective for critical systems where stability and user experience are paramount, 
     and it allows me to detect issues early without affecting the entire user base."
-------------------------------------------------------------------------------------------------------------
40) Recreate
    -The Recreate strategy in Kubernetes is the simplest form of deployment where all the existing Pods of an application 
     are terminated first, and then new Pods with the updated version are created.
    -There is no overlap — the old version goes down completely before the new version comes up.
    -Because of this, there is a short period of downtime during the update. 
    -This approach is not ideal for highly available applications, but it can be useful in certain scenarios.

    -I use the Recreate strategy when:
    -I cannot run the old and new versions of the app at the same time due to conflicts, like shared database schemas or file locks.
     Or when downtime is acceptable, such as in development or internal environments.
    -This strategy is simple and predictable, but not recommended for production where availability and zero-downtime are important."
-------------------------------------------------------------------------------------------------------------
41) Pod Identity Association
-------------------------------------------------------------------------------------------------------------
42) Istio-Service Mesh > Purpose > How it works
    Istio is an open-source service mesh that provides a dedicated infrastructure layer to manage communication 
    between microservices in a Kubernetes cluster.
    It helps you secure, control, and observe service-to-service communication — without changing application code.
          How Istio Works (Explain to Interviewer)
                    -Istio works by deploying a sidecar proxy (Envoy) alongside each application pod. 
                    -These proxies intercept all incoming and outgoing traffic and communicate with the Istio control plane (Istiod), 
                    which manages configuration, security policies, and telemetry.”
          You can break it down into the following components and workflow:
1. Data Plane — Envoy Proxies
Each application pod gets a sidecar container (Envoy proxy).
All inbound and outbound traffic flows through this proxy.
These proxies handle:
    Traffic routing
    TLS encryption
    Retries/failovers
    Rate limiting
    Observability (metrics, logs, traces)
Think of Envoy as a "smart traffic cop" controlling how traffic enters/exits a service.

2. Control Plane — Istiod
Central brain of Istio.
Manages configuration of all proxies.
Distributes routing rules, security policies, and telemetry configuration.
Also handles:
    Service discovery
    Certificate management
    Policy enforcement

Workflow Example
Imagine a request from Service A to Service B:
    1. Service A’s app sends a request.
    2. The Envoy proxy attached to A intercepts it.
    3. Based on Istio’s rules (like routing, retries), it forwards the request to B.
    4. The Envoy proxy on B receives it and sends it to the actual app.
    5. Both proxies collect telemetry (logs, metrics, traces) for monitoring.
    All of this happens without modifying application code.

Why Use Istio? (Importance)
    Security - mTLS between services, access policies
    Traffic Control - Canary deployments, A/B testing, traffic shifting
    Observability Metrics - via Prometheus, logs, Jaeger tracing
    Policy Enforcement - Rate limits, blacklisting, authorization
Real-World Use Cases
1. Zero-trust Security
Ensure encrypted, authenticated communication between services using mTLS.
2. Canary Deployment
Gradually route traffic (e.g., 10%, 50%, 100%) to a new version of a service using VirtualService
3. Fault Injection / Testing Resilience
Simulate delays or errors between services to test how they behave under failure.
4. Traffic Mirroring
Mirror live traffic to a test version of a service without affecting production.
---
📄 Example YAML (Traffic Splitting)

apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
  - reviews
  http:
  - route:
    - destination:
        host: reviews
        subset: v1
      weight: 80
    - destination:
        host: reviews
        subset: v2
      weight: 20
➡️ This splits traffic 80% to version 1 and 20% to version 2.

How to Conclude (To Interviewer)
In summary, Istio enables fine-grained control over service communication, improves security and visibility, 
and supports advanced deployment strategies — all without changing application code. That’s why it’s commonly used in 
production-grade microservices architectures.”
-------------------------------------------------------------------------------------------------------------
43) Calico-Network Plugin
-------------------------------------------------------------------------------------------------------------
44) Pod Security Admission
-------------------------------------------------------------------------------------------------------------
45) Network Policy
-------------------------------------------------------------------------------------------------------------
46) RBAC
    -Security mechanism in Kubernetes used to control who can access what resources and perform what actions in the cluster.
    -It ensures that users or applications only get the minimum required permissions (principle of least privilege).
        Why is RBAC Important?
            -Prevents unauthorized access to sensitive resources.
            -Helps meet compliance and security standards.
            -Enables fine-grained access control.
            -Essential for multi-tenant clusters and team-based operations.
        Component Description
            -Role - Defines permissions within a namespace. Example: view Pods in dev namespace.
            -ClusterRole - Defines permissions cluster-wide (or for all namespaces). Example: view all Pods in all namespaces.
            -RoleBinding - Assigns a Role to a user/service account within a namespace.
            -ClusterRoleBinding - Assigns a ClusterRole to a user/service account cluster-wide.
        Summary
            -RBAC = permission system for Kubernetes.
            -Uses Roles, ClusterRoles, and Bindings.
            -Helps you secure your cluster with least-privilege access.
            -Critical for multi-user and production-grade environments.
-------------------------------------------------------------------------------------------------------------
47) Role Binding
    -RoleBinding grants namespace-scoped permissions to a user, group, or service account by linking it to a Role.
        Features:
            -Grants limited access within a namespace.
            -Used in Role-Based Access Control (RBAC).
            -Supports binding to users, groups, and service accounts.
-------------------------------------------------------------------------------------------------------------
48) Cluster Binding
    -ClusterRoleBinding grants cluster-wide permissions by binding a user/service account to a ClusterRole.
        Features:
            -Not namespace-bound.
            -Required for access to cluster-level resources (e.g., nodes, persistent volumes).
            -Needed by controllers and monitoring systems.
-------------------------------------------------------------------------------------------------------------
49) Service Account
-------------------------------------------------------------------------------------------------------------
50) Kube Config
    -kubeconfig is a configuration file that stores information about how to connect to Kubernetes clusters — 
     including server addresses, user credentials, and contexts.
      Features:
          -Supports multiple clusters and users.
          -Enables context switching between dev, staging, and prod.
          -Stores auth data like certificates, tokens, etc.
      Use Case:
          -A developer wants to deploy to a staging cluster:
            kubectl --context=staging apply -f app.yaml
          ✅ No need to manually enter credentials each time.
-------------------------------------------------------------------------------------------------------------
51) Topology
    Refers to how workloads (Pods) are distributed across cluster infrastructure such as zones, regions, or nodes.
        Features:
          -Ensures fault tolerance by spreading Pods.
          -Reduces cross-zone network costs.
          -Controlled using topology keys like:
                    topology.kubernetes.io/zone
                    kubernetes.io/hostname
-------------------------------------------------------------------------------------------------------------
52) Annotations
    -Annotations are key-value metadata attached to Kubernetes objects. Unlike labels, they are not used for selection or scheduling but to store auxiliary data.
        Features:
            -Not used by Kubernetes core for logic.
            -Can store large or structured data.
            -Read by external tools or controllers.
-------------------------------------------------------------------------------------------------------------
53) Kubernetes Federation
-------------------------------------------------------------------------------------------------------------
54) Multi-Cluster Management Solutions: Rancher or Anthos
    Multi-cluster management means centrally managing multiple Kubernetes clusters — which could be spread across:
        Different cloud providers (AWS, Azure, GCP)
        On-prem data centers
        Hybrid or edge environments
    Think of it like a control plane that oversees all your clusters, enabling consistent policies, access, deployment, and monitoring.

    Why Multi-Cluster Management Is Needed
        Failure in one cluster Disaster recovery from another
        Different geographies Serve users with low latency
        Regulatory compliance Data stays in region-specific clusters
        Dev/Test/Prod separation Environment isolation
        Scalability Distribute workloads intelligently

-------------------------------------------------------------------------------------------------------------
55)  Multi Tenancy
-------------------------------------------------------------------------------------------------------------
56) API
    API (Application Programming Interface) is a set of rules or protocols that allows one software application to communicate with another.
    It defines how requests should be made, what data format to use, and how systems should respond — just like a contract between 
    two applications.
          Key Features of an API
                Abstraction - Hides the internal details of how a system works. Only exposes required endpoints.
                Modularity - Allows separation of concerns — front-end and back-end can work independently.
                Reusability - APIs can be reused across different apps or systems.
                Scalability - APIs make it easier to scale services independently.
                Security - APIs support authentication and authorization (like tokens, API keys, OAuth).
                Standardization - Most APIs use standards like REST, JSON, or GraphQL.
                Interoperability - Allows different systems and technologies to work together (e.g., Java app calling a Python API).
          Types of APIs
                1. REST API – Uses HTTP, easy to use, JSON-based.
                2. SOAP API – XML-based, used in enterprise systems.
                3. GraphQL API – Flexible queries, modern alternative to REST.
                4. gRPC – Fast binary communication, suitable for microservices.
          Real-World Example
                A mobile food delivery app (like Zomato) calls:
                Location API to get user’s city.
                Restaurant API to list nearby restaurants.
                Payment API to process online payments.
        Why APIs are Important
              Connect systems (e.g., frontend <-> backend, app <-> database)
              Enable third-party integrations
              Power microservices communication
              Allow automation (e.g., scripts calling cloud APIs)
              Used in DevOps (e.g., calling Kubernetes or Terraform APIs)
-------------------------------------------------------------------------------------------------------------
57) Kubernetes Operators
    -Kubernetes Operators are software extensions that use custom resources to manage applications and their components like a 
     human operator would.
    -They extend Kubernetes’ capabilities by automating the entire lifecycle of complex applications — 
     including install, upgrade, backup, scaling, and failover.
    -A Kubernetes Operator is a method of packaging, deploying, and managing a Kubernetes application using Custom Resource Definitions (CRDs) 
     and a controller that watches and reconciles the state.
    Why Use Operators?
       -Kubernetes knows how to manage basic resources (like Pods, Services, Deployments), but complex applications 
       (like databases, messaging systems) need custom logic — e.g., how to:
       Safely upgrade a database cluster
       Handle leader elections
       Restore from backup
       An operator codifies that domain-specific knowledge into software.
-------------------------------------------------------------------------------------------------------------
58) TLS termination
    SSL Termination is the process of decrypting HTTPS traffic (SSL/TLS) at the load balancer or ingress controller 
    before forwarding it to backend services over plain HTTP.
         Features:
            Happens at Ingress Controller, Load Balancer, or Reverse Proxy
            Offloads SSL overhead from backend servers
            Improves performance and centralized certificate management
        Use Case:
            In Kubernetes, NGINX Ingress Controller handles SSL termination using TLS certificates, while backend pods only deal with HTTP.
-------------------------------------------------------------------------------------------------------------
59) How Scaling is Managed for Statefulset
-------------------------------------------------------------------------------------------------------------
60) OIDC(OpenID Connect)
    OIDC is an authentication protocol built on top of OAuth 2.0 that allows users to verify their identity using 
    a third-party identity provider (IdP) (e.g., Google, Azure AD, Keycloak).
      Features:
          Built on OAuth 2.0
          Provides ID tokens (JWT) that contain user information
          Supports Single Sign-On (SSO)
          Commonly used in Kubernetes, CI/CD, and cloud platforms for login
      Use Case:
          You can log in to a website using your Google or GitHub account — that’s OIDC in action.
-------------------------------------------------------------------------------------------------------------
61) How to upgrade worker nodes
-------------------------------------------------------------------------------------------------------------
62) TCP (Transmission Control Protocol)
    TCP is a connection-oriented protocol in the transport layer that ensures reliable, ordered, and error-checked delivery of data.
         Features:
              Ensures all packets are delivered
              Re-transmits lost packets
              Maintains connection state
              Slower but reliable
      Use Case:
              Used in web browsing (HTTP/HTTPS), SSH, SMTP (email).
-------------------------------------------------------------------------------------------------------------
 63) UDP (User Datagram Protocol)
    UDP is a connectionless protocol in the transport layer that sends data without ensuring delivery or order.
          Features:
                No connection setup
                No guarantee of delivery
                Lightweight and faster than TCP
                Suitable for real-time use cases
          Use Case:
                Used in video streaming, VoIP, DNS, online gaming — where speed matters more than perfect reliability.
-------------------------------------------------------------------------------------------------------------
diff between logs and describe
Zaegar/Zepkins
Velero
etcd snapshotting



