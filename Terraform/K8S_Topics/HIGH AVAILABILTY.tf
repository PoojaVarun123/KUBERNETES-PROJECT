======================================================================================================
                                  High Availabilty of EKS Cluster
======================================================================================================

There are 3 major parts of EKS HA that you control:
------------------------------------------------------------------------------------------------------
1. Deploy Worker Nodes Across Multiple Availability Zones (AZs)
Why: If an AZ goes down, pods can reschedule to another AZ with minimal impact.
How: If using eksctl, simply specify multiple subnets across AZs:

# eks-ha-cluster.yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
  name: eks-ha-cluster
  region: us-east-1
vpc:
  subnets:
    private:
      us-east-1a: { id: subnet-aaa }
      us-east-1b: { id: subnet-bbb }
      us-east-1c: { id: subnet-ccc }
nodeGroups:
  - name: ng-general
    instanceType: t3.medium
    desiredCapacity: 3
    minSize: 3
    maxSize: 6
    privateNetworking: true
    subnets:
      - subnet-aaa
      - subnet-bbb
      - subnet-ccc
This deploys nodes evenly across AZs with auto scaling.
-----------------------------------------------------------------------------------------------------
2️. Distribute Your Pods Across Nodes and AZs
Use affinity and topologySpreadConstraints

spec:
  topologySpreadConstraints:
    - maxSkew: 1
      topologyKey: "topology.kubernetes.io/zone"
      whenUnsatisfiable: ScheduleAnyway
      labelSelector:
        matchLabels:
          app: my-app
This ensures pods are balanced across zones, not just nodes.
-----------------------------------------------------------------------------------------------------
3️. Use LoadBalancer with Cross-Zone Support
If you're exposing services:
Use an AWS NLB or ALB Ingress Controller
Enable cross-zone load balancing in the NLB settings
This ensures your app stays reachable even if an AZ fails.
-----------------------------------------------------------------------------------------------------
4️. Add Multiple Node Groups (Optional)
Use multiple node groups to:
-Separate workloads (prod vs dev)
-Use different instance types (e.g., spot vs on-demand)
-Run apps with different scheduling requirements

Example using eksctl:
nodeGroups:
  - name: general
    instanceType: t3.medium
    minSize: 3
    subnets: [subnet-aaa, subnet-bbb, subnet-ccc]
  - name: gpu
    instanceType: p3.2xlarge
    minSize: 1
    taints:
      - key: dedicated
        value: gpu
        effect: NoSchedule
-----------------------------------------------------------------------------------------------------
5️. Enable Cluster Autoscaler
Let Kubernetes scale your nodes dynamically:

helm install cluster-autoscaler \
  --namespace kube-system \
  oci://registry-1.docker.io/bitnamicharts/cluster-autoscaler \
  --set autoDiscovery.clusterName=eks-ha-cluster \
  --set awsRegion=us-east-1 \
  --set extraArgs.balance-similar-node-groups=true
-----------------------------------------------------------------------------------------------------
6️. Use Highly Available Storage
For stateful apps:
Use EBS CSI Driver with replication (or use EFS for NFS-style HA)
For databases: consider Amazon RDS or EKS + StatefulSet + backup
Example PV using EBS CSI:

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ebs-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: gp3
-----------------------------------------------------------------------------------------------------
7️. Use Managed Add-ons in HA Mode
Make sure:
CoreDNS has 2+ replicas
Kube-proxy is installed per node
AWS VPC CNI is up-to-date

kubectl -n kube-system scale deployment coredns --replicas=2

Summary: HA in EKS
Component	What You Do
-Control Plane	> Already HA (3 AZs by AWS) ✅
-Worker Nodes	> Deploy across AZs using multiple subnets
-Pods	> Use topologySpreadConstraints or anti-affinity
-Services	> Use NLB/ALB with cross-zone load balancing
-Storage	> Use EBS/EFS for persistent volumes
-Node Autoscaling	> Enable Cluster Autoscaler
================================================================================================================
