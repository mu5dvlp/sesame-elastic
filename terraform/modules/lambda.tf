###############################################################################
# Lambda execution role
###############################################################################
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name               = "${local.name_prefix}-lambda-exec-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

###############################################################################
# Lambda function + EventBridge schedule
###############################################################################
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${local.name_prefix}-sesame-monitor"
  retention_in_days = 14

  tags = local.common_tags
}

resource "aws_lambda_function" "sesame_monitor" {
  function_name    = "${local.name_prefix}-sesame-monitor"
  filename         = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)
  role             = aws_iam_role.lambda_exec.arn
  handler          = "presentation.lambda_function.handler"
  runtime          = "python3.12"
  timeout          = 60

  environment {
    variables = {
      ELASTICSEARCH_HOST = aws_eip.elk.public_ip
      ELASTICSEARCH_PORT = "9200"
      SESAME_API_KEY     = var.sesame_api_key
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda,
    aws_iam_role_policy_attachment.lambda_basic_execution,
  ]

  tags = local.common_tags
}

resource "aws_cloudwatch_event_rule" "sesame_schedule" {
  name                = "${local.name_prefix}-sesame-schedule"
  description         = "Trigger Lambda to collect Sesame device status"
  schedule_expression = var.schedule_expression

  tags = local.common_tags
}

resource "aws_cloudwatch_event_target" "sesame_lambda" {
  rule      = aws_cloudwatch_event_rule.sesame_schedule.name
  target_id = "SesameMonitorLambda"
  arn       = aws_lambda_function.sesame_monitor.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sesame_monitor.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.sesame_schedule.arn
}
