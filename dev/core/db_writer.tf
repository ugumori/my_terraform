
resource "aws_ecr_repository" "db_writer" {
  name                 = "raspi_gpio/db_writer"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  encryption_configuration {
    encryption_type = "KMS"
  }
}


resource "aws_lambda_function" "db_writer" {
  function_name = "raspi_gpio_db_writer_${local.env}"
  role          = aws_iam_role.db_writer.arn
  package_type  = "Image"
  memory_size   = "512"
  timeout       = "100"
  image_uri     = "${local.aws_account_id}.dkr.ecr.${local.region}.amazonaws.com/${aws_ecr_repository.db_writer.name}:latest"
  architectures = ["arm64"]
  
  lifecycle {
    ignore_changes = [image_uri]
  }

  environment {
    variables = {
      LOG_LEVEL = "DEBUG"
    }
  }

  tracing_config {
    mode = "PassThrough"
  }

  depends_on = [ aws_ecr_repository.db_writer ]
}


resource "aws_lambda_event_source_mapping" "un_gw_log_stream_handler_source" {
  batch_size                         = "1" #10
  bisect_batch_on_function_error     = "false"
  enabled                            = "true"
  event_source_arn                   = aws_kinesis_stream.raspi_stream.arn
  function_name                      = aws_lambda_function.db_writer.arn
  starting_position                  = "LATEST"
  maximum_batching_window_in_seconds = "0"
  maximum_record_age_in_seconds      = "86400"
  maximum_retry_attempts             = "1"
  parallelization_factor             = "1"
}



resource "aws_iam_role" "db_writer" {
  name                 = "raspi_gpio_db_writer_role"
  description          = "Allows database writer of lambda to call AWS services."
  assume_role_policy   = data.aws_iam_policy_document.parser_assume_policy.json
  max_session_duration = "3600"
}

data "aws_iam_policy_document" "parser_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      identifiers = [
        "lambda.amazonaws.com"
      ]
      type = "Service"
    }
  }
}

resource "aws_iam_role_policy_attachment" "db_writer" {
  role       = aws_iam_role.db_writer.name
  policy_arn = each.key
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaKinesisExecutionRole"
  ])
}


