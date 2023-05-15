data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "template_file" "dynamo_policy" {
  template = file("${path.module}/templates/dynamo_policy.json")

  vars = {
    region    = data.aws_region.current.name
    table_arn = aws_dynamodb_table.reservations.arn
    acct_id   = data.aws_caller_identity.current.account_id
  }

}

data "template_file" "eks_policy" {
  template = file("${path.module}/templates/eks_policy.json")

  vars = {
    cluster_name = var.cluster_name
  }

}

data "template_file" "secrets_policy" {
  template = file("${path.module}/templates/secrets_policy.json")

  vars = {
    secret_arn = var.tfc_secret_arn
  }

}

data "template_file" "cloudwatch_policy" {
  template = file("${path.module}/templates/cloudwatch_policy.json")
}

resource "aws_iam_role" "reservations_lambdas" {
  name               = "reservations-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  inline_policy {
    name   = "TableWrite"
    policy = data.template_file.dynamo_policy.rendered
  }

  inline_policy {
    name   = "CloudwatchWrite"
    policy = data.template_file.cloudwatch_policy.rendered
  }

}

resource "aws_iam_role" "delete_cluster_lambda" {
  name               = "delete-cluster-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  inline_policy {
    name   = "DeleteEKS"
    policy = data.template_file.eks_policy.rendered
  }

  inline_policy {
    name   = "CloudwatchWrite"
    policy = data.template_file.cloudwatch_policy.rendered
  }

}

resource "aws_iam_role" "deploy_cluster_lambda" {
  name               = "deploy-cluster-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  inline_policy {
    name   = "TfcSecretRead"
    policy = data.template_file.secrets_policy.rendered
  }

  inline_policy {
    name   = "CloudwatchWrite"
    policy = data.template_file.cloudwatch_policy.rendered
  }

}

resource "aws_iam_role" "generic_lambda" {
  name               = "generic-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  inline_policy {
    name   = "CloudwatchWrite"
    policy = data.template_file.cloudwatch_policy.rendered
  }

}