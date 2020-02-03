data "template_file" "redrive" {
  template = "${file("${path.module}/redrive.json.template")}"
  vars = {
    arn = data.terraform_remote_state.failures-queue.outputs.arn
    max_receive = terraform.workspace == "prod" ? 3 : 1
  }
}
resource "aws_sqs_queue" "queue" {
  name                       = "{{ cookiecutter.name }}-${terraform.workspace}"
  visibility_timeout_seconds = var.timeout_sec * 6
  redrive_policy             = data.template_file.redrive.rendered
  tags = {
    Project     = "{{cookiecutter.project}}"
    Managed_By  = "terraform"
    Service     = "{{cookiecutter.name}}"
    Environment = terraform.workspace
  }
}

# Allow our specific SNS Topic to send messags to our SQS queue
data "aws_iam_policy_document" "{{ cookiecutter.name}}-read-sns" {
  version   = "2012-10-17"
  policy_id = "sns<>sqs"
  statement {
    sid    = "snssqssqssns"
    effect = "Allow"
    actions = [
      "SQS:SendMessage"
    ]
    resources = [aws_sqs_queue.queue.arn]
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values = [
        data.terraform_remote_state.TOPIC.outputs.arn
      ]
    }
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_sqs_queue_policy" "sns-policy" {
  queue_url = aws_sqs_queue.queue.id
  policy    = data.aws_iam_policy_document.{{ cookiecutter.name }}-read-sns.json
}

resource "aws_sns_topic_subscription" "topic-subscription" {
  topic_arn = data.terraform_remote_state.TOPIC.outputs.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.queue.arn
  filter_policy = jsonencode(
    {
      event_type = ["{{cookiecutter.subscription_event_type}}"]
    }
  )
}
