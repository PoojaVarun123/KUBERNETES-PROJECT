======================================================================================
                  Option 1: Install EBS CSI Using EKS Addon
======================================================================================
✅ Terraform Code

resource "aws_eks_addon" "ebs_csi_addon" {
  cluster_name             = aws_eks_cluster.my_cluster.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.30.0-eksbuild.1" # Optional: latest at time of writing
  service_account_role_arn = aws_iam_role.ebs_csi_irsa_role.arn
}

> This is the simplest and recommended method if you use AWS-managed EKS.

======================================================================================
✅ Option 2: Install EBS CSI Using Helm
======================================================================================
✅ 1. Create the ServiceAccount (IRSA)

# ebs-sa.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ebs-csi-controller-sa
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::<ACCOUNT_ID>:role/AmazonEKS_EBS_CSI_DriverRole

kubectl apply -f ebs-sa.yaml
==========================================================================================

✅ 2. Install via Helm

helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
helm repo update

helm upgrade --install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver \
  --namespace kube-system \
  --set controller.serviceAccount.create=false \
  --set controller.serviceAccount.name=ebs-csi-controller-sa \
  --set enableVolumeScheduling=true \
  --set enableVolumeResizing=true \
  --set enableVolumeSnapshot=true


============================================================================================
