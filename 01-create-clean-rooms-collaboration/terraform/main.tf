data "aws_caller_identity" "account_2" {
  provider = aws.account_2
}

data "terraform_remote_state" "prepare_glue_database" {
  backend = "local"

  config = {
    path = "${path.module}/../../../00-prepare-glue-database/terraform.tfstate"
  }
}

resource "random_string" "uid" {
  length  = 4
  upper   = false
  special = false
}

resource "aws_cleanrooms_collaboration" "clean_rooms_lab_analysis_collab" {
  name                     = "clean_rooms_lab_analysis_collab"
  description              = "clean_rooms_lab_analysis_collab"
  creator_member_abilities = []
  creator_display_name     = "member-data-source"
  query_log_status         = "DISABLED"

  member {
    account_id       = data.aws_caller_identity.account_2.account_id
    display_name     = "flight-data-store"
    member_abilities = ["CAN_QUERY", "CAN_RECEIVE_RESULTS"]
  }
}

resource "aws_cleanrooms_configured_table" "members_table" {
  name            = "members_table"
  analysis_method = "DIRECT_QUERY"
  allowed_columns = [
    "city",
    "clv",
    "country",
    "education",
    "enrollment month",
    "enrollment type",
    "enrollment year",
    "gender",
    "loyalty card",
    "marital status",
    "salary",
    "postal code",
    "province"
  ]

  table_reference {
    database_name = "aws-clean-rooms-lab"
    table_name    = "members"
  }
}

resource "aws_cloudformation_stack" "collab_membership_account_1" {
  name          = "aws-clean-rooms-lab-collab-membership-${random_string.uid.id}"
  template_body = file("${path.module}/templates/create-collaboration-membership-account-01.yaml")

  parameters = {
    CollaborationId = aws_cleanrooms_collaboration.clean_rooms_lab_analysis_collab.id
  }
}

resource "aws_cloudformation_stack" "collab_membership_account_2" {
  provider = aws.account_2

  name          = "aws-clean-rooms-lab-collab-membership-${random_string.uid.id}"
  template_body = file("${path.module}/templates/create-collaboration-membership-account-02.yaml")

  parameters = {
    CollaborationId  = aws_cleanrooms_collaboration.clean_rooms_lab_analysis_collab.id
    ResultBucketName = data.terraform_remote_state.prepare_glue_database.outputs.query_result_bucket_account_2.id
  }
}
