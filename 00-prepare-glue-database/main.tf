data "aws_caller_identity" "account_1" {}

data "aws_caller_identity" "account_2" {
  provider = aws.account_2
}

resource "random_string" "uid" {
  length  = 4
  upper   = false
  special = false
}
