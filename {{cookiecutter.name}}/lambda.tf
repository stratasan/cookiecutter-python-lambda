resource "aws_lambda_function" "function" {
  function_name    = "{{cookiecutter.name}}-${terraform.workspace}"
  runtime          = var.runtime
  filename         = var.zipfile
  source_code_hash = base64sha256(filebase64(var.zipfile))
  handler          = "handler.handler"
  role             = aws_iam_role.iam_role.arn
  memory_size      = var.memory_mb
  timeout          = var.timeout_sec

  environment {
    variables = {
      ENVIRONMENT = "{{cookiecutter.project}}-${terraform.workspace}"
      SERVICE     = "{{cookiecutter.name}}"
      SENTRY_DSN  = var.sentry_dsn
      VAULT_ADDR  = var.vault_address
      VAULT_ROOT  = var.vault_root
    }
  }

  tags = {
    env        = "{{cookiecutter.project}}-${terraform.workspace}"
    service    = "{{cookiecutter.name}}"
    Managed_by = "terraform"
    Project    = "{{cookiecutter.project}}"
  }

  # This enables X-Ray tracing but to get actual traces you need to install
  # the python aws_xray_sdk library
  tracing_config {
    mode = "Active"
  }

  vpc_config {
    subnet_ids         = terraform.workspace == "prod" ? data.terraform_remote_state.prod-vpc.outputs.private_subnet_ids : data.terraform_remote_state.dev-vpc.outputs.private_subnet_ids
    security_group_ids = [terraform.workspace == "prod" ? data.terraform_remote_state.prod-vpc.outputs.security_group_ids : data.terraform_remote_state.dev-vpc.outputs.security_group_ids]
  }

  # Only build this function once we have the IAM role w/ correct execution rights and the CWL group
  depends_on = [
    aws_iam_role_policy_attachment.basic-execution,
    aws_cloudwatch_log_group.log-group
  ]

  layers = [
    data.terraform_remote_state.function_layer.outputs.arn
  ]
}

# Build a CW Log Group
resource "aws_cloudwatch_log_group" "log-group" {
  name              = "/aws/lambda/{{cookiecutter.name}}-${terraform.workspace}"
  retention_in_days = 14
}

# Deliver SQS messages to our function
resource "aws_lambda_event_source_mapping" "sqs-connection" {
  event_source_arn = aws_sqs_queue.queue.arn
  batch_size       = 1
  function_name    = aws_lambda_function.function.arn
}

# Subscribe all log events to our DataDog function
resource "aws_cloudwatch_log_subscription_filter" "test_lambdafunction_logfilter" {
  name            = "{{cookiecutter.name}} logs to DataDog lambda"
  filter_pattern  = ""
  log_group_name  = aws_cloudwatch_log_group.log-group.name
  destination_arn = "arn:aws:lambda:us-east-1:298433512871:function:serverlessrepo-Datadog-Log-For-loglambdaddfunction-1K80LPNVDGQKQ"
}
