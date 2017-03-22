output "ert_iam_user_name" {
  value = "${aws_iam_user.ert_iam_user.name}"
}

output "ert_iam_user_access_key" {
  value = "${aws_iam_access_key.ert_iam_user_access_key.id}"
}

output "ert_iam_user_secret_access_key" {
  value = "${aws_iam_access_key.ert_iam_user_access_key.secret}"
}

output "region" {
  value = "${var.region}"
}

