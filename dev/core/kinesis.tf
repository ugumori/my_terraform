resource "aws_kinesis_stream" "raspi_stream" {
  encryption_type  = "NONE"
  name             = "raspi_stream"
  retention_period = "24"
  shard_count      = "1"
}

resource "aws_iam_user" "raspi_machine" {
  name = "raspi_machine"
}

resource "aws_iam_user_policy_attachment" "raspi_machine" {
  user       = aws_iam_user.raspi_machine.name
  policy_arn = aws_iam_policy.allow_put_record_to_kinesis.arn
#   policy_arn = each.key
#   for_each = toset([
#     aws_iam_policy.allow_put_record_to_kinesis.arn
#   ])

  depends_on = [aws_iam_policy.allow_put_record_to_kinesis]
}

resource "aws_iam_policy" "allow_put_record_to_kinesis" {
  name        = "allow-put-record-to-kinesis"
  description = ""
  policy      = data.aws_iam_policy_document.allow_put_record_to_kinesis.json
}

data "aws_iam_policy_document" "allow_put_record_to_kinesis" {
  statement {
    actions = ["kinesis:PutRecord"]
    effect  = "Allow"

    resources = [
      aws_kinesis_stream.raspi_stream.arn
    ]
  }
}
