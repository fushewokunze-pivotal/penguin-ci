resource "aws_iam_user" "ert_iam_user" {
  name = "${var.env_name}_ert_iam_user"
}

resource "aws_iam_access_key" "ert_iam_user_access_key" {
  user = "${aws_iam_user.ert_iam_user.name}"
}

data "template_file" "ert" {
  template = "${file("${path.root}/templates/iam_ert_buckets_policy.json")}"

  vars {
    cloud_controller_bucket_arn  = "${aws_s3_bucket.cloud_controller.arn}"
  }
}

resource "aws_iam_policy" "ert" {
  name   = "${var.env_name}_ert"
  policy = "${data.template_file.ert.rendered}"
}

resource "aws_iam_policy_attachment" "ert_user_policy" {
  name       = "${var.env_name}_ert_iam_user_policy"
  users      = ["${aws_iam_user.ert_iam_user.name}"]
  policy_arn = "${aws_iam_policy.ert.arn}"
}

resource "aws_iam_user" "bosh_iam_user" {
  name = "${var.env_name}_bosh_iam_user"
}

resource "aws_iam_access_key" "bosh_iam_user_access_key" {
  user = "${aws_iam_user.bosh_iam_user.name}"
}

data "template_file" "bosh" {
  template = "${file("${path.root}/templates/iam_bosh_deploy_policy.json")}"
}

resource "aws_iam_policy" "bosh" {
  name   = "${var.env_name}_bosh"
  policy = "${data.template_file.bosh.rendered}"
}

resource "aws_iam_policy_attachment" "bosh_user_policy" {
  name       = "${var.env_name}_bosh_iam_user_policy"
  users      = ["${aws_iam_user.bosh_iam_user.name}"]
  policy_arn = "${aws_iam_policy.bosh.arn}"
}

###AWS SERVICE BROKER

#RDS POLICY

data "template_file" "aws_service_broker_rds" {
  template = "${file("${path.root}/templates/aws_service_broker_rds_policy.json")}"
}

resource "aws_iam_policy" "aws_service_broker_rds" {
  name   = "${var.env_name}_aws_service_broker_rds"
  description = "Service Broker for AWS Service Key policy for rds"
  policy = "${data.template_file.aws_service_broker_rds.rendered}"
}

resource "aws_iam_policy_attachment" "aws_sb_user_policy_rds" {
  name       = "${var.env_name}_bosh_iam_user_policy"
  users      = ["${aws_iam_user.bosh_iam_user.name}"]
  policy_arn = "${aws_iam_policy.aws_service_broker_rds.arn}"
}

#S3 Policy

data "template_file" "aws_service_broker_s3" {
  template = "${file("${path.root}/templates/aws_service_broker_s3_policy.json")}"
}

resource "aws_iam_policy" "aws_service_broker_s3" {
  name   = "${var.env_name}_aws_service_broker_s3"
  description = "Service Broker for AWS Service Key policy for s3"
  policy = "${data.template_file.aws_service_broker_s3.rendered}"
}

resource "aws_iam_policy_attachment" "aws_sb_user_policy_s3" {
  name       = "${var.env_name}_bosh_iam_user_policy"
  users      = ["${aws_iam_user.bosh_iam_user.name}"]
  policy_arn = "${aws_iam_policy.aws_service_broker_s3.arn}"
}


#SQS Policy

data "template_file" "aws_service_broker_sqs" {
  template = "${file("${path.root}/templates/aws_service_broker_sqs_policy.json")}"
}

resource "aws_iam_policy" "aws_service_broker_sqs" {
  name   = "${var.env_name}_aws_service_broker_sqs"
  description = "Service Broker for AWS Service Key policy for sqs"
  policy = "${data.template_file.aws_service_broker_sqs.rendered}"
}

resource "aws_iam_policy_attachment" "aws_sb_user_policy_sqs" {
  name       = "${var.env_name}_bosh_iam_user_policy"
  users      = ["${aws_iam_user.bosh_iam_user.name}"]
  policy_arn = "${aws_iam_policy.aws_service_broker_sqs.arn}"
}

#Dynamodb

data "template_file" "aws_service_broker_dynamodb" {
  template = "${file("${path.root}/templates/aws_service_broker_dynamodb_policy.json")}"
}

resource "aws_iam_policy" "aws_service_broker_dynamodb" {
  name   = "${var.env_name}_aws_service_broker_dynamodb"
  description = "Service Broker for AWS Service Key policy for dynamodb"
  policy = "${data.template_file.aws_service_broker_dynamodb.rendered}"
}

resource "aws_iam_policy_attachment" "aws_sb_user_policy_dynamodb" {
  name       = "${var.env_name}_bosh_iam_user_policy"
  users      = ["${aws_iam_user.bosh_iam_user.name}"]
  policy_arn = "${aws_iam_policy.aws_service_broker_dynamodb.arn}"
}

# pcf

data "template_file" "PCFInstallationPolicy" {
  template = "${file("${path.root}/templates/iam_aws_service_broker_buckets_policy.json")}"
}

resource "aws_iam_policy" "PCFInstallationPolicy" {
  name   = "${var.env_name}_PCFInstallationPolicy"
  description = "Installation Policy for PCF"
  policy = "${data.template_file.PCFInstallationPolicy.rendered}"
}

resource "aws_iam_policy_attachment" "aws_sb_user_policy_pcf" {
  name       = "${var.env_name}_bosh_iam_user_policy"
  users      = ["${aws_iam_user.bosh_iam_user.name}"]
  policy_arn = "${aws_iam_policy.PCFInstallationPolicy.arn}"
}

