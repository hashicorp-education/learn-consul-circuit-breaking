module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.26.6"

  cluster_name    = local.cluster_name
  cluster_version = "1.26"

  cluster_addons = {
    aws-ebs-csi-driver = { most_recent = true }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

    # Needed by the aws-ebs-csi-driver
    iam_role_additional_policies = [
      "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    ]

    # Disabling and using externally provided security groups
    create_security_group = false
    attach_cluster_primary_security_group = true
  }

  node_security_group_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = null
  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 3

      vpc_security_group_ids = [
        aws_security_group.node_group_one.id
      ]
    }
  }
}

# Uninstalls consul resources (API Gateway controller, Consul-UI, and AWS ELB, and removes associated AWS resources)
# on terraform destroy
resource "null_resource" "kubernetes_consul_resources" {
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete svc/consul-ui --namespace consul && kubectl delete svc/api-gateway --namespace consul && kubectl delete svc/prometheus-server --namespace consul"
  }
  depends_on = [module.eks]
}
