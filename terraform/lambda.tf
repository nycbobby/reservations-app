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

data "template_file" "policy" {
  template = file("${path.module}/templates/dynamo_policy.json")

  vars = {
    region    = data.aws_region.current.name
    table_arn = aws_dynamodb_table.reservations.arn
    acct_id   = data.aws_caller_identity.current.account_id
  }

}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  inline_policy {
    name   = "TableWrite"
    policy = data.template_file.policy.rendered
  }

}
