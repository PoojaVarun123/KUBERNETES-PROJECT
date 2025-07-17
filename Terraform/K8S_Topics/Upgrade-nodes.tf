===========================================================================================================
                                          UPGRADE OF NODES
===========================================================================================================
Upgrading worker nodes is a critical part of Kubernetes maintenance to ensure we get the latest security patches, 
features, and bug fixes. The process depends on the cluster type — whether it's managed (like EKS, GKE, AKS) or self-managed (like kubeadm).

Let me explain both — starting with kubeadm-based clusters:”
----------------------------------------------------------------------------------------------------------------
For Self-Managed Cluster (kubeadm)
> "Here’s the step-by-step upgrade strategy I follow for worker nodes:

✅ 1. Drain the Node
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data
This safely evicts pods to other nodes so they can keep running.
Ensures no application downtime.

✅ 2. Upgrade kubelet & kubectl on the Node
apt-get update && apt-get install -y kubelet=1.29.X-00 kubectl=1.29.X-00
> (Version must match the control plane or be one minor version behind.)

✅ 3. Restart the kubelet
systemctl daemon-reexec
systemctl restart kubelet

✅ 4. Uncordon the Node
kubectl uncordon <node-name>
This allows the scheduler to place new pods on the node.

"I repeat this node-by-node to avoid downtime and maintain stability."
==================================================================================================================================
For Managed Clusters (like AWS EKS)
In EKS, worker node upgrades are slightly different because the control plane is managed by AWS. Here’s how I do it with managed node groups:"

1. Create a New Node Group with the Desired Version
Use the console, eksctl, or Terraform to create a new node group (e.g., v1.29).
Nodes come with the latest AMI containing updated kubelet.

2. Cordon and Drain Old Nodes
kubectl cordon <old-node>
kubectl drain <old-node> --ignore-daemonsets --delete-emptydir-data

3. Delete the Old Node Group
After confirming everything is migrated and healthy:
eksctl delete nodegroup --cluster <cluster-name> --name <old-nodegroup>

4. Validate
Ensure all workloads are running on the new version.
Check kubectl get nodes to confirm versions.

---------------------------------------------------------------------------------------------------
🔒 Best Practices I Follow
Always upgrade control plane first (for kubeadm).
Test upgrades in staging before prod.
Use PodDisruptionBudgets (PDBs) to prevent multiple pods being disrupted.
Monitor node health post-upgrade (CPU, memory, logs).
Automate upgrades using tools like kured, Cluster Autoscaler, or GitOps (ArgoCD/Terraform).
---------------------------------------------------------------------------------------------------
Conclusion
To sum it up, upgrading worker nodes involves careful planning: draining pods, updating software or node groups, 
validating workloads, and minimizing impact through automation and best practices.”
