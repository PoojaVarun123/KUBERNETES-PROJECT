======================================================================================================
                                  Kubernetes Architecture
======================================================================================================
                                        API Server
======================================================================================================
The API Server is the central management interface of Kubernetes.
It acts as a gatekeeper, message broker, and traffic controller for all communication within the Kubernetes cluster.
---
Think of it Like:
-A reception desk or traffic cop that:
-Accepts requests (from users or internal components)
-Validates and authenticates them
-Updates the cluster state in etcd
-Notifies other components
---
Entry Point - Accepts all kubectl, UI, or automation tool requests
Authentication -  Verifies who made the request (User, ServiceAccount)
Authorization - Checks what that user is allowed to do (RBAC/ABAC)
Admission Control - Validates or modifies resources before they're saved
State Management - Reads/writes resource state from/to etcd
Communication Hub - Notifies other components (controllers, schedulers, kubelets)
---
Say you run this:
kubectl apply -f my-deploy.yaml

Step-by-step:
1. Request Sent → kubectl sends an HTTP request to the API Server
2. Authentication → The API server verifies your identity
3. Authorization → Checks your permissions (e.g., can you create a Deployment?)
4. Admission Controllers → Optional plugins that mutate or validate requests
5. Persist to etcd → Valid requests are stored in etcd as the  desired state.
6. Notify Components:
  -Scheduler sees the new pod and schedules it
  -Controller Manager tracks changes
  -Kubelet gets instructions to run the pod
---
🔁 Example Use Cases
Action API Server Role
kubectl get pods 
    -Reads the pod list from etcd and returns it to the client
    -A new pod is created, validated, and stored in etcd, and notifies the scheduler
    -A node dies, Controller Manager updates status via API Server
    -Kubelet wants to report status. Sends update to API Server
    -Prometheus scraping metrics, reads/metrics from the API Server endpoint
======================================================================================================
                                    Kubernetes Scheduler
======================================================================================================
The Scheduler is a control plane component in Kubernetes responsible for assigning pods to nodes.
It decides which node should run a newly created pod, based on resource availability, policies, and rules.
---
Role of the Scheduler:
Once a pod is created (e.g., from a Deployment, Job, or StatefulSet), it does not yet have a node assigned.
The scheduler watches the API server for such unscheduled pods and:
1. Evaluates all nodes in the cluster
2. Selects the best node using scoring and filtering algorithms
3. Binds the pod to the selected node by updating the pod's spec.nodeName
---
🔁 Step-by-Step Flow:
1. You apply a Deployment YAML with 3 replicas.
2. Controller Manager creates 3 pods → but no node is assigned yet.
3. Scheduler sees "pending" pods.
4. It evaluates nodes → picks the best one for each pod.
5. It updates the pod spec with nodeName = selected-node.
6. Kubelet on that node pulls the image and runs the pod.
---
What the Scheduler Considers (Scoring & Filtering)
Type Examples
Resource Fit > Does the node have enough CPU, memory?
Node Affinity/Anti-Affinity > Does the pod prefer or avoid certain nodes?
Taints and Tolerations  > Is the pod allowed on tainted nodes?
Pod Affinity/Anti-Affinity > Should pods be placed together or apart?
Topology Spread > Spread pods across zones/regions/nodes
Node Selector/Labels > Is the node labeled as required by the pod?
---
Input:
Unscheduled Pods from API Server (those with no. .spec.nodeName)

Output:
Pod updated with .spec.nodeName = selected-node
That updated pod info goes back to the API server
---
Example:
You deploy a pod with this config:
resources:
  requests:
    cpu: "500m"
    memory: "1Gi"

There are 5 nodes. The scheduler checks:
-Which nodes have ≥500m CPU and 1Gi memory free?
-Does the pod tolerate any taints on those nodes?
-Any affinity/anti-affinity?
-Scores all valid nodes
-Picks the highest-scoring node
-Binds the pod
---
🧠 Think of the Scheduler Like:
> A matchmaker who watches for pods needing homes and intelligently decides which house (node) fits best based on compatibility and capacity.
---
What Scheduler Doesn’t Do:
It doesn’t run pods or pull images (kubelet does that).
It doesn’t retry pods if they crash (controller manager does).
It doesn’t monitor the health of pods.
---
Summary:
Assign pods to nodes 
Consider resources, taints, and labels 
Make scheduling decisions 
🔍 What Exactly Does the Kubelet Do in Kubernetes?

The Kubelet is the primary agent running on each Kubernetes worker node. It is responsible for managing the lifecycle of pods and containers on its node.
Kubelet is a node-level agent that ensures the containers described in PodSpecs are running and healthy.
---
Responsibilities of the Kubelet
-Registers Node - Registers the node with the Kubernetes control plane (API Server).
-Watches for Pod Specs -  Listens for Pod definitions assigned to its node (from API Server).
-Runs Containers - Instructs the container runtime (e.g., containerd) to pull images and start containers.
-Monitors Pod/Container Health - Continuously checks if containers are healthy (via readiness/liveness probes).
-Reports Node & Pod Status  - Sends periodic status updates (NodeCondition, PodCondition) to the API server.
-Manages Pod Lifecycle - Starts, restarts, or kills containers based on PodSpec and state.
-Handles Volume Mounting - Mounts persistent volumes defined in the pod to the container.
-Applies Secrets/Configs - Injects ConfigMaps and Secrets into the pods as environment variables or files.
-Exec / Logs / Port-Forward - Enables commands like kubectl exec, kubectl logs, and kubectl port-forward by connecting directly to running containers.

---
How Kubelet Works — Step-by-Step:
1. Kubelet starts on a node.
2. It registers the node with the API server (unless done manually).
3. It watches for pod specs that are scheduled to this node.
4. When a pod is scheduled:
-It tells the container runtime to pull the image and run it.
-It sets up volumes, configmaps, secrets, and networking
5. It keeps checking if:
-Pods are still running.
-Containers are healthy (via health probes).
6. If a container fails, kubelet can restart it (based on the policy).
7. It reports pod and node status back to the control plane.

Example Real-Life Tasks by Kubelet
-Restart crashed containers (if restartPolicy: Always).
-Kill a pod during a node shutdown.
-Mount /var/lib/kubelet/pods/... volumes.
-Run init containers before main containers.

======================================================================================================================
                                                         ETCD
======================================================================================================================
etcd is the key-value database used by Kubernetes to store all cluster state, like pods, nodes, configmaps, secrets, deployments, and more.
It is the single source of truth for everything happening inside your Kubernetes cluster.
---
Think of etcd like:
A Git repository + Database combo where Kubernetes stores everything it knows about the cluster — both desired state and actual state.
---
What etcd Does
Role Description
    -Stores Configuration - Keeps every detail about the cluster: deployments, pods, services, etc.
    -State Management - Stores both the desired and current state of all objects
    -Watch Support - Allows API Server to "watch" for changes (e.g., pod added, node removed)
    -Cluster Coordination - Helps components (like controllers, kubelets) stay in sync
    -High-Availability Store - Can be run as a distributed, fault-tolerant, consistent DB
---
What Gets Stored in etcd?
All Kubernetes resources like:
Deployments + Pods + Services + ConfigMaps + Secrets + PersistentVolumes + Node info + RBAC roles + API server metadata + Events
---
🔁 Example Flow
Step-by-step:
1. You run:
kubectl apply -f deployment.yaml
2. API Server validates and stores the deployment object in etcd.
3. The Controller Manager, Scheduler, and Kubelets watch etcd (via API server) for updates.
4. Any time something changes (pod crashes, node goes offline), etcd gets updated again by the API server.

-All components only talk to API Server
-API Server reads/writes to etcd
-etcd is always the truth keeper
---
⚖️ Why etcd is Critical
If etcd goes down or gets corrupted → your entire cluster becomes unusable.
That’s why it's:
Backed up regularly
Secured with TLS
Often run as a cluster of 3+ nodes for HA
---
📦 etcd in Real Use Cases
New Deployment applied - Stores the deployment spec
Node crashes - etcd updates node condition
Pod recreated automatically - Controller reads/writes via etcd
kubectl get pods - API Server reads from etcd
HorizontalPodAutoscaler scales a pod - Writes the new pod to etcd
---
Feature etcd Does:
-Stores cluster state 
-Provides strong consistency 
-Supports watch 
All Kubernetes secrets and sensitive data are stored in etcd — make sure it is encrypted and protected!
==================================================================================================================
                                                Kube Proxy
==================================================================================================================
kube-proxy is a networking component that runs on every worker node in a Kubernetes cluster.
It is responsible for routing traffic to the right pod using iptables, IPVS, or eBPF rules.
---
Think of kube-proxy like:
A traffic manager that makes sure when you send a request to a Kubernetes Service, it finds and routes it to the correct pod(s) behind that service.
---
kube-proxy Responsibilities
Service Discovery - Watches the API Server for Service and Endpoint updates.
Traffic Routing - Routes external or internal traffic to the appropriate pod(s).
Load Balancing - Distributes traffic across multiple pods (round-robin or IPVS).
Network Rules - Setup uses iptables or IPVS to create rules for routing packets.
Cluster Networking - Enables service-to-pod communication inside the cluster.
---
How kube-proxy Works
1. A Service is created (e.g., ClusterIP, NodePort, LoadBalancer).
2. kube-proxy sees the new service via the API Server.
3. It sets up iptables or IPVS rules on the node:
-Routes any request to the Service IP or NodePort
-Forwards it to one of the backend pods (Endpoints)
---
Example Scenario
You create a Service like this:

kind: Service
metadata:
  name: my-nginx
spec:
  selector:
    app: nginx
  ports:
    - port: 80
      targetPort: 80
  type: ClusterIP

Here’s what kube-proxy does:
-Watches API Server for this new service.
-Finds the matching pods (based on app: nginx).
Sets up iptables rules to forward all traffic from 10.96.0.1:80 (ClusterIP) to one of the nginx pods.
---
kube-proxy Modes
-iptables - Default in most clusters. Sets up NAT rules to forward traffic.
-ipvs Advanced routing method using Linux IPVS. More scalable and efficient.
-userspace Legacy mode. Rarely used now.
---
Real Life Flow (ClusterIP Service)
1. Pod A wants to talk to Service B (ClusterIP = 10.96.0.5:80)
2. Pod A makes a request to 10.96.0.5:80
3. kube-proxy intercepts the request
4. Forwards to one of the backend pod IPs (e.g., 192.168.1.23:80)
---
📤 Types of Services kube-proxy Supports
Service Type Handled by kube-proxy? Notes
ClusterIP ✅ Default type, internal only
NodePort ✅ Exposes app on all node IPs
LoadBalancer ✅ (with cloud support) For public exposure
ExternalName ❌ Handled via DNS

Addons
-coreDNS
-Metrics server
---
✅ Summary
Component kube-proxy
-Runs On Every worker node
-Watches Services & Endpoints via API Server
-Main Role -Route traffic to correct pods using iptables/IPVS
-Supports ClusterIP, NodePort, LoadBalancer
-Does NOT Run containers or resolve DNS

Container Runtime
The Container Runtime is the software responsible for running containers on a worker node.
It works under the kubelet and is the engine that pulls images, creates, starts, stops, and deletes containers.
---
Think of it like:
A virtual machine manager, but for containers instead of VMs.
If the kubelet says "run this pod", the container runtime is what runs the containers.
---
🎯 Responsibilities of Container Runtime
Image Management - Pulls container images (from Docker Hub, ECR, etc.)
Container Lifecycle - Creates, starts, stops, restarts, and deletes containers
Container Isolation - Runs containers with proper namespaces, cgroups (process, network, file system isolation)
Health & Metrics - Reports container status back to kubelet
Volume & Filesystem - Setup Mounts volumes, configs, and secrets into containers
Networking Setup - Helps set up networking for the containers (with help from CNI plugins)
---
Common Container Runtimes:
-containerd - Lightweight, high-performance runtime. Most popular today.
-CRI-O - Designed for Kubernetes, used with OpenShift.
-Docker -Previously used by Kubernetes (now deprecated).
-gVisor, Kata Containers For enhanced isolation (security-focused)
---
How It Works in Kubernetes
1. kubelet receives a PodSpec from the API Server
2. kubelet parses the spec and sends instructions to the container runtime
3. The container runtime:
   - Pulls the image
   - Creates container namespaces
   - Mounts volumes
   - Starts the container
4. kubelet monitors container status via runtime
---
Example Pod Spec → Runtime Action

containers:
- name: myapp
  image: nginx:latest

Kubelet tells container runtime:
 Pull nginx:latest
 Create container named myapp
 Set environment, ports, volumes
 Start container
---
CRI: Container Runtime Interface
Kubernetes does not talk directly to Docker or containerd. Instead, it talks via the CRI (Container Runtime Interface).
So container runtime must support CRI — containerd and CRI-O do; Docker doesn’t (hence it was deprecated in v1.24+).
---
Kubelet Instructs the container runtime to run containers
Container Runtime actually pulls the image and runs the container
Examples containerd, CRI-O, Docker (deprecated)
Interface Used CRI (Container Runtime Interface)

==================================================================================================================================
                          Kubernetes Components – How They Interact Behind the Scenes
==================================================================================================================================
Goal of Kubernetes:
To ensure that your applications run reliably by constantly matching the actual state of the cluster to the desired state defined in YAML files.
To do this, Kubernetes uses a modular architecture with components that each perform a specific job. Let’s walk through how they connect and interact.
---
🧩 High-Level Component Overview
💻 1. User or DevOps
> Uses kubectl or a CI/CD tool to submit a request (kubectl apply, create, get, etc.)
---
🏗️ Full Interaction Flow (Step-by-Step)
---
✅ Step 1: User Sends Request
You apply a Deployment:
kubectl apply -f my-deployment.yaml
kubectl sends a REST request to the API Server.
---
🚪 Step 2: API Server Processes the Request
Validates the request.
Authenticates & authorizes the user.
Applies Admission Controllers (if any).
Writes the desired state (Deployment spec) into etcd.

✅ etcd now has:

Deployment:
  replicas: 3
  template:
    containers:
      - image: nginx
---
🤖 Step 3: Controller Manager Reacts
-Watches the etcd state via the API Server.
-Sees that 3 pods are desired but 0 are running.
-It creates 3 Pod objects and updates API Server, which writes to etcd.
---
Step 4: Scheduler Assigns Pods to Nodes
-Scheduler sees unscheduled pods via the API Server.
-It scores and selects the best node for each pod.
-It binds each pod to a node by updating the pod’s .spec.nodeName.
---
🧱 Step 5: Kubelet Executes the Pod
On each assigned node:
The Kubelet:
-Watches for pods assigned to its node.
-Gets the pod spec from API Server.
-Calls the Container Runtime (like containerd) to:
    -Pull the image
    -Create & start the container
    -Mounts volumes, applies configs/secrets
    -Reports container health and pod status to API Server
---
🔁 Step 6: Continuous Monitoring & Updates
Kubelet keeps checking if containers are healthy.
Controller Manager reconciles the desired and current state:
If a pod crashes, it asks to create a new one.
API Server updates status in etcd.
---
🔀 Step 7: kube-proxy Handles Traffic
When a Service is created:
-kube-proxy (on each node) watches the API Server.
-Sets up iptables or IPVS rules to route traffic to backend pods.

Now your pods can:
Talk to each other via Service IP
Receive traffic from outside (via NodePort / LoadBalancer)

==================================================================================================================================
                          Kubernetes Components – How They Interact Behind the Scenes
==================================================================================================================================
The Kubernetes Scheduler decides which node a pod should run on, based on several factors like resource availability, affinity rules, taints/tolerations, and more.
---
In Simple Terms:
The scheduler matches the pod’s requirements with the node’s available resources and constraints, then chooses the best possible node using a two-step process: 
Filtering + Scoring
---
1. Filtering Phase (Elimination Step)
-The scheduler filters out nodes that can’t run the pod. Reasons include:
-Filter Condition What It Checks

✅ CPU/Memory (Resource Requests) - Is there enough CPU & RAM on the node for the pod?
✅ NodeSelector - Does the node match nodeSelector labels in pod spec?
✅ Affinity/Anti-affinity - Does the pod request to run with/away from certain pods?
✅ Taints/Tolerations - Can the pod tolerate the taints on the node?
✅ PodTopologySpread - Does the pod need to spread across zones/racks?
✅ Volume Limits - Does the node exceed CSI volume limits?
✅ NodeName - Was a specific node requested?
✅ HostPort Conflicts -  Are there port clashes with existing pods?

Example: A pod requesting 500m CPU and 256Mi RAM will not be scheduled to a node with only 200m free CPU.
---
🏆 2. Scoring Phase (Ranking Step)
Now that the scheduler has a list of eligible nodes, it assigns a score to each one based on how “good” the placement would be.Scoring Policy What It Prefers

⭐ Least Requested Resources - Spread load evenly across nodes
⭐ Balanced Resource Allocation - Pick nodes with balanced CPU and memory usage
⭐ Affinity Rules - Prefer nodes with matching preferredDuringScheduling
⭐ Taint Toleration - Priority Prefer nodes that don't require tolerations
⭐ Image Locality - Prefer nodes that already have the container image
⭐ Topology Spread Constraints - Prefer pods to be distributed across zones/racks
---
Final Step:
-The node with the highest score is selected.
-The Scheduler binds the pod to that node by updating the pod’s .spec.nodeName.
---
Example Pod with Constraints

apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  containers:
  - name: web
    image: nginx
    resources:
      requests:
        cpu: "500m"
        memory: "256Mi"
  nodeSelector:
    disktype: ssd
  tolerations:
  - key: "env"
    value: "prod"
    operator: "Equal"
    effect: "NoSchedule"
---
In this case, only nodes with:
-Enough CPU/memory
-A label disktype=ssd
-A taint env=prod: NoSchedule (which is tolerated by pod)

...will be eligible.

---
👀 How to View Scheduling Decisions
View pod status:
kubectl get pod myapp -o wide
Enable scheduler logs (if self-managed cluster)
Use kubectl describe pod to see reasons if not scheduled.
--
Filtering - Remove nodes that can’t meet the pod’s requirements
Scoring - Rank the remaining nodes based on best-fit logic
Binding - Pod is assigned (bound) to the highest-ranked node
========================================================================================================
