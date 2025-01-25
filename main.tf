data "aws_subnets" "available-subnets"{
    filter {
        name = "tag:Name"
        values = ["Ekart-Public-*"]
    }
}

resource "aws_eks_cluster" "Ekart-Cluster" {
  name = "Ekart-Cluster"
  role_arn = aws_iam_role.example.arn

  vpc_config {
    subnet_ids = data.aws_subnets.available-subnets.ids
  }

  depends_on = [ 
    aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
    awsaws_iam_role_policy_attachment.example-AmazonEKSVPCResourceController,
  ]

}

output "endpoint" {
    value = aws_eks_cluster.Ekart-Cluster.endpoint
}

output "kubeconfig-certificate-authority-data"{
    value = aws_eks_cluster.Ekart-Cluster.certificate_authority[0].data
}

resource "aws_eks_node_group" "Ekart-Node-Group" {
  cluster_name    = aws_eks_cluster.Ekart-Cluster.name
  node_group_name = "Ekart-Node-Group"
  node_role_arn   = aws_iam_role.worker.arn
  subnet_ids      = data.aws_subnets.available-subnets.ids
  capacity_type   = "ON_DEMAND"
  disk_size       = "20"
  instance_types  = ["t2.micro"]
  labels = tomap({ env = "dev" })
 
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
 
  update_config {
    max_unavailable = 1
  }
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly
    ]  
}