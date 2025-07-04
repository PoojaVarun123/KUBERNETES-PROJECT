
1. What is Kubernetes?
Kubernetes is an open-source container orchestration platform used to automate the deployment, scaling, and management of containerized applications.
---
2. What are K8s?
K8s is a short form for Kubernetes, where "8" represents the eight letters between "K" and "s". It is widely used in the tech industry as shorthand for Kubernetes.
---
3. What is orchestration in software and DevOps?
Orchestration refers to the automated configuration, coordination, and management of computer systems, applications, and services. In DevOps, it involves automating the deployment and scaling of applications.
---
4. How are Kubernetes and Docker related?
Docker is a containerization platform, while Kubernetes is an orchestration platform that manages and scales Docker containers in production environments.
---
5. What are the main differences between Docker Swarm and Kubernetes?
Scalability: Kubernetes scales better.
Ecosystem: Kubernetes has a richer ecosystem.
Networking: Kubernetes has a more advanced networking model.
Complexity: Docker Swarm is simpler to set up but less feature-rich.
---
6. What is the difference between deploying applications on hosts and containers?
Hosts: Applications run directly on the OS, sharing system resources.
Containers: Applications run in isolated environments, enhancing portability and consistency.
---
7. What are the features of Kubernetes?
Automated rollouts and rollbacks
Service discovery and load balancing
Storage orchestration
Self-healing
Secret and configuration management
Horizontal scaling
---
8. What are the main components of Kubernetes architecture?
Master Node (Control Plane)
Worker Nodes
etcd (key-value store)
Kube-apiserver
Kube-scheduler
Kube-controller-manager
Kubelet
Kube-proxy
---
9. What is the role of the master node in Kubernetes?
The master node manages the Kubernetes cluster, maintaining the desired state and controlling scheduling, scaling, and deployment.
---
10. What is the function of the Kube-apiserver?
Kube-apiserver is the front-end of the Kubernetes control plane. It validates and configures data for the API objects, including pods, services, and controllers.
---
11. What is the difference between a node and a pool node in Kubernetes?
Node: A single machine in the cluster.
Node Pool: A group of nodes with identical configurations used for scaling and management.
---
12. What information does the node status include?
Node conditions (Ready, MemoryPressure, DiskPressure)
Allocatable resources (CPU, memory)
Labels and annotations
Node name and role
---
13. Which processes run on the Kubernetes Master Node?
The Kubernetes Master Node runs the control plane components responsible for managing the cluster:
kube-apiserver: The front-end for the Kubernetes control plane; handles REST requests.
etcd: The key-value store that holds all cluster data.
kube-scheduler: Assigns newly created pods to nodes.
Kube-controller-manager: Runs controllers like Node Controller, Replication Controller, etc.
cloud-controller-manager (optional): Manages cloud-specific control logic.
---
14. What is a Pod in Kubernetes?
A Pod is the smallest deployable unit in Kubernetes.
It represents a single instance of a running process in the cluster and can contain one or more tightly coupled containers that share:
-Network (IP and port space)
-Storage (volumes)
-Lifecycle
---
15. What is the role of the kube-scheduler?
The kube-scheduler is responsible for:
-Selecting the best available node to run newly created pods based on:
-Resource requirements
-Node taints/tolerations
-Affinity rules
-Resource availability
It ensures balanced and efficient workload distribution.
---
16. What is a Kubelet?
The Kubelet is an agent running on each worker node. It:
-Watches for PodSpecs through the API Server.
-Ensures the containers described in those PodSpecs are running and healthy.
-Communicates with the container runtime (like Docker or containerd).
---
17. What is the difference between a StatefulSet and a Deployment?
Feature > Deployment > StatefulSet
Pod Identity >Pods are stateless and interchangeable > Each Pod has a stable, unique identity
Network > No stable hostname > Each Pod gets stable DNS name
Storage > Uses shared or ephemeral storage > Uses persistent, dedicated storage
Use Case > Web apps, stateless microservices > Databases, queues, stateful apps
---
18. What is a Service in Kubernetes?
A Service is a stable, abstract way to expose an application running as Pods. It:
-Provides a single DNS name and IP for a set of Pods.
-Handles load balancing across Pods.
Types:
-ClusterIP (default, internal)
-NodePort (external via node IP)
-LoadBalancer (external via cloud provider)
-ExternalName (DNS-based redirection)
---
19. What are DaemonSets in Kubernetes?
A DaemonSet ensures that a copy of a specific Pod runs on every (or specific) node in the cluster.
Used for node-level services such as:
-Log collectors (Fluentd, Filebeat)
-Monitoring agents (Prometheus Node Exporter)
-Security agents
---
20. What is Heapster in Kubernetes?
Heapster was a performance monitoring and metrics collection tool for Kubernetes clusters.
It collected resource usage data (CPU, memory) and sent it to backends like InfluxDB, Grafana.
Note: Heapster is now deprecated. Modern Kubernetes uses:
-Metrics Server for resource metrics.
-Prometheus + Grafana for advanced monitoring.
---
21. What is a Namespace in Kubernetes?
A Namespace is a way to divide cluster resources between multiple users or teams.
It provides scope for names of resources, allowing separation and management of resources within the same cluster.
---
22. What is Ingress in Kubernetes?
Ingress manages external access to services in a cluster, typically over HTTP/HTTPS. It uses Ingress Controllers to provide:
-Routing rules
-SSL termination
-Path-based routing
---
23. What is the Kubernetes Controller Manager?
The Controller Manager runs the core controllers that regulate the cluster's desired state (like replicating pods, managing nodes, etc.).
---
24. What are the types of Controller Managers?
Node Controller
Replication Controller
Endpoints Controller
ServiceAccount Controller
Job Controller
Namespace Controller
---
25. What is etcd in Kubernetes?
etcd is the key-value store that holds all cluster data, including configuration, state, and metadata. It is the source of truth for the Kubernetes control plane.
---
26. What are the different types of services in Kubernetes?
ClusterIP (default, internal)
NodePort
LoadBalancer
ExternalName
Headless Service (no cluster IP)
---
27. What is ClusterIP?
ClusterIP exposes the service on an internal IP within the cluster. It is not accessible externally.
---
28. Difference between ReplicaSet and ReplicationController?
ReplicaSet > supports label selectors > Newer, supports Deployments
ReplicationController> Only equality-based selectors > Legacy controller
---
29. What is a Headless Service?
A Headless Service (ClusterIP: None) gives direct access to individual pods without load balancing, useful for stateful applications.
---
30. What is kubectl?
kubectl is the Kubernetes command-line tool used to deploy applications, inspect cluster resources, and manage clusters.
---
31. What is a Kubelet?
The Kubelet is an agent on each node that ensures the containers are running as defined in the PodSpec. (See Q16 above.)
---
32. What is a Helm chart?
A Helm chart is a package manager template for Kubernetes resources. It allows easy deployment, upgrade, and versioning of applications.
---
33. How does Kubernetes handle security and access control?
RBAC (Role-Based Access Control)
Network Policies
ServiceAccounts
Secrets & TLS
Admission Controllers
---
34. How do Pods communicate across nodes?
Kubernetes uses CNI plugins (like Calico, Flannel) to provide pod-to-pod communication across nodes via a flat network.
---
35. How do rolling updates work in Kubernetes?
Kubernetes gradually replaces old Pods with new ones while keeping the service available, as controlled by Deployment strategies.
---
36. What are Labels and Selectors?
Labels: Key-value pairs attached to objects.
Selectors: Used to select and group objects by label for services, replication, and policies.
---
37. What is a ConfigMap?
A ConfigMap stores non-sensitive configuration data (like environment variables, config files) that can be consumed by Pods.
---
38. What is a Network Policy?
A Network Policy defines how Pods can communicate with each other and with other network endpoints, based on rules.
---
39. What are Taints and Tolerations?
Taints: Applied to nodes to prevent pods from scheduling unless the pod has the right toleration.
Tolerations: Allow pods to be scheduled on tainted nodes.
---
40. How does Kubernetes manage storage orchestration?
Through PersistentVolumes (PV), PersistentVolumeClaims (PVC), and StorageClasses for dynamic provisioning of storage.
---
41. What is a Custom Operator?
A Custom Operator extends Kubernetes to manage custom resources and their lifecycle, automating operational tasks.
---
42. How does Kubernetes handle rolling back deployments?
Using:
kubectl rollout undo deployment <name> Kubernetes can revert to previous ReplicaSet versions safely.
---
43. What is a Pod Disruption Budget (PDB)?
A PDB ensures that a minimum number of pods remain available during voluntary disruptions like node drains or updates.
---
44. How does Kubernetes handle node failures?
Node Controller detects unhealthy nodes.
Pods are rescheduled to healthy nodes automatically.
Replication ensures app availability.
---
45. What is Prometheus in Kubernetes?
Prometheus is an open-source monitoring system that collects metrics from Kubernetes and allows alerting and visualization (often with Grafana).
---
46. How to achieve high availability in Kubernetes?
Multiple master nodes
Pod replication across nodes
Auto-scaling and load balancing
Persistent storage with failove
---
47. What is CNI in Kubernetes?
The Container Network Interface (CNI) manages networking, IP assignment, and pod communication across nodes
---
48. What is the purpose of a ServiceAccount?
A ServiceAccount provides identity to pods, allowing them to authenticate to the API server and access resources securely.
---
49. What is Horizontal Pod Autoscaler (HPA)?
HPA automatically scales the number of pods based on CPU/memory usage or custom metrics.
---
51. What is a Kubernetes Admission Controller?
An Admission Controller is a plugin that intercepts API requests to enforce policies or mutate objects before persistence.

