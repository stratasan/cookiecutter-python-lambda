# Allows the lambda function to assume this role
data "aws_iam_policy_document" "assume-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    effect = "Allow"
  }
}

// Role for this lambda
resource "aws_iam_role" "iam_role" {
  name               = "{{cookiecutter.name}}-${terraform.workspace}"
  description        = "Role used for the {{cookiecutter.name}} lambda"
  assume_role_policy = data.aws_iam_policy_document.assume-role.json
}

# Define the actions
data "aws_iam_policy_document" "data-access" {
  // Lambdas running in an VPC must be able to do certain EC2 things
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      // X-ray Functionality
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
      "xray:GetSamplingRules",
      "xray:GetSamplingTargets",
      "xray:GetSamplingStatisticSummaries"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      # https://docs.aws.amazon.com/lambda/latest/dg/with-sqs.html
      "SQS:ReceiveMessage",
      "SQS:DeleteMessage",
      "SQS:GetQueueAttributes",
    ]
    resources = [
      aws_sqs_queue.queue.arn
    ]
  }

  /* This statement allows the lambda to interact with S3
  statement {
    effect = "Allow"
    actions = [
      #
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "${data.terraform_remote_state.com-stratasan-star-uploads.outputs.arn}",
      "${data.terraform_remote_state.com-stratasan-star-uploads.outputs.arn}/*",
    ]
  }
  */
}

# build a role policy w/ the document above
resource "aws_iam_role_policy" "data-access" {
  name   = "{{cookiecutter.name}}-access-${terraform.workspace}"
  role   = aws_iam_role.iam_role.name
  policy = data.aws_iam_policy_document.data-access.json
}

# This attaches an AWS-managed policy called AWSLambdaBasicExecutionRole
# allowing this role to create and write into a cloudwatch log group
resource "aws_iam_role_policy_attachment" "basic-execution" {
  role       = aws_iam_role.iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
