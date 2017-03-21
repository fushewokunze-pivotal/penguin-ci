data "template_file" "aws_service_broker_dynamo" {
  template = "${file("${path.root}/templates/aws_service_broker_dynamo_policy.json")}"
}

resource "aws_iam_policy" "aws_service_broker_dynamo" {
  name   = "${var.env_name}_aws_service_broker_dynamo"
  description = "Service Broker for AWS Service Key policy for dynamo"
  policy = "${data.template_file.aws_service_broker_dynamo.rendered}"
}
