Step Action

1 Enable OIDC on EKS /
2 Create IAM policy /
3 Create IRSA role + SA /
4 Install EBS CSI driver /
5 Create StorageClass /
6 Create PVC /
7 Mount PVC in Pod /
8 Verify volume write /

for dyanamic provisioning:
      -storage class
      -PV is automatically created by EBS CSI driver
      -PVC is required

for static provisioning:
      -storage class
      -PV is required
      -PVC is required

      
