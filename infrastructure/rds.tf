data "template_file" "aws_service_broker_rds" {
  template = "${file("${path.root}/templates/aws_service_broker_rds_policy.json")}"
}

resource "aws_iam_policy" "aws_service_broker_rds" {
  name   = "${var.env_name}_aws_service_broker_rds"
  description = "Service Broker for AWS Service Key policy for rds"
  policy = "${data.template_file.aws_service_broker_rds.rendered}"
}
