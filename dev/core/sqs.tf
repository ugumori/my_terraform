resource "aws_sqs_queue" "raspi_gpio_control" {
  name = "raspi_gpio_control"
  delay_seconds = 0
  # エラー時100秒で再処理する（Lambdaのタイムアウト時間以上にする）.
  visibility_timeout_seconds = 100
  receive_wait_time_seconds = 20
  # 3回程度リトライする. 300(message_retention_seconds) / 100(visibility_timeout_seconds) ≒ 3
  message_retention_seconds = 300
}


resource "aws_sqs_queue_policy" "raspi_gpio_control" {
  queue_url = aws_sqs_queue.raspi_gpio_control.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "${aws_sqs_queue.raspi_gpio_control.arn}/SQSDefaultPolicy",
  "Statement": [
    {
      "Sid": "raspi_gpio_control",
      "Effect": "Allow",
      "Principal": {"AWS": "*"},
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.raspi_gpio_control.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "*"
        }
      }
    }
  ]
}
POLICY
}
