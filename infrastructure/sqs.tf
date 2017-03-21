data "template_file" "aws_service_broker_sqs" {
  template = "${file("${path.root}/templates/aws_service_broker_sqs_policy.json")}"
}

resource "aws_iam_policy" "aws_service_broker_sqs" {
  name   = "${var.env_name}_aws_service_broker_sqs"
  description = "Service Broker for AWS Service Key policy for sqs"
  policy = "${data.template_file.aws_service_broker_sqs.rendered}"
}
