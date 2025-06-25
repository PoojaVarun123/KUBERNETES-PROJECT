======================================================================================================
                                     OIDC PROVIDER
======================================================================================================
data "aws_eks_cluster" "eks" {
  name = "eks-prod"
}

data "tls_certificate" "oidc_thumbprint" {
  url = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc_thumbprint.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
}
=======================================================================================================
