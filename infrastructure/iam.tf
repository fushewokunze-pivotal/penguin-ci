provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}


resource "aws_iam_user" "ert_iam_user" {
  name = "${var.env_name}_ert_iam_user"
}

resource "aws_iam_access_key" "ert_iam_user_access_key" {
  user = "${aws_iam_user.ert_iam_user.name}"
}


resource "aws_iam_user" "aws_service_broker_iam_user" {
  name = "${var.env_name}_aws_service_broker_iam_user"
}

resource "aws_iam_access_key" "aws_service_broker_iam_user_access_key" {
  user = "${aws_iam_user.aws_service_broker_iam_user.name}"
}

data "template_file" "aws_service_broker" {
  template = "${file("${path.root}/templates/iam_aws_service_broker_buckets_policy.json")}"
}

resource "aws_iam_policy" "aws_service_broker" {
  name   = "${var.env_name}_aws_service_broker"
  policy = "${data.template_file.aws_service_broker.rendered}"
}

resource "aws_iam_policy_attachment" "aws_service_broker_user_policy" {
  name       = "${var.env_name}_aws_service_broker_iam_user_policy"
  users      = ["${aws_iam_user.aws_service_broker_iam_user.name}"]
  policy_arn = "${aws_iam_policy.aws_service_broker.arn}"
}
