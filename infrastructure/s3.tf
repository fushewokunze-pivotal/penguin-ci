data "template_file" "aws_service_broker_s3" {
  template = "${file("${path.root}/templates/aws_service_broker_s3_policy.json")}"
}

resource "aws_iam_policy" "aws_service_broker_s3" {
  name   = "${var.env_name}_aws_service_broker_s3"
  description = "Service Broker for AWS Service Key policy for S3"
  policy = "${data.template_file.aws_service_broker_s3.rendered}"
}
