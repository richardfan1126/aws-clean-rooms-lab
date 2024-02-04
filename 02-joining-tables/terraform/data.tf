data "aws_caller_identity" "account_1" {}

data "aws_caller_identity" "account_2" {
  provider = aws.account_2
}

data "terraform_remote_state" "prepare_glue_database" {
  backend = "local"

  config = {
    path = "${path.module}/../../00-prepare-glue-database/terraform.tfstate"
  }
}

resource "random_string" "uid" {
  length  = 4
  upper   = false
  special = false
}
