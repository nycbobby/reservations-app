data "aws_iam_policy_document" "assume_role_eks" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks_role" {
  name               = "${var.cluster_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_eks.json
}

resource "aws_iam_role_policy_attachment" "cluster_attach" {
  for_each   = toset(["AmazonEKSClusterPolicy", "AmazonEKSVPCResourceController"])
  policy_arn = "arn:aws:iam::aws:policy/${each.key}"
  role       = aws_iam_role.eks_role.name
}

data "aws_iam_policy_document" "assume_role_ec2" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks_role_nodegroup" {
  name               = "${var.node_group_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ec2.json
}

resource "aws_iam_role_policy_attachment" "nodegroup_attach" {
  for_each = toset([
    "AmazonEKSWorkerNodePolicy",
    "AmazonEKS_CNI_Policy",
    "AmazonEC2ContainerRegistryReadOnly"
  ])
  policy_arn = "arn:aws:iam::aws:policy/${each.key}"
  role       = aws_iam_role.eks_role_nodegroup.name
}

