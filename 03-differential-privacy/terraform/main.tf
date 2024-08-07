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

resource "aws_cleanrooms_collaboration" "clean_rooms_lab_analysis_collab" {
  name                     = "clean_rooms_lab_collab_03"
  description              = "clean_rooms_lab_collab_03"
  creator_member_abilities = []
  creator_display_name     = "member-data-source"
  query_log_status         = "ENABLED"

  member {
    account_id       = data.aws_caller_identity.account_2.account_id
    display_name     = "data-consumer"
    member_abilities = ["CAN_QUERY", "CAN_RECEIVE_RESULTS"]
  }
}

resource "aws_cloudformation_stack" "members_table" {
  name          = "aws-clean-rooms-lab-members-table-${random_string.uid.id}"
  template_body = file("${path.module}/templates/create-members-table.yaml")

  parameters = {
    TableName             = "members"
    GlueDatabaseName      = split(":", data.terraform_remote_state.prepare_glue_database.outputs.glue_database_account_1.id)[1]
    GlueTableName         = split(":", data.terraform_remote_state.prepare_glue_database.outputs.members_table.id)[2]
    DataConsumerAccountId = data.aws_caller_identity.account_2.account_id
  }
}

resource "aws_cloudformation_stack" "collab_membership_account_1" {
  name          = "aws-clean-rooms-lab-collab-membership-${random_string.uid.id}"
  template_body = file("${path.module}/templates/create-collaboration-membership.yaml")

  parameters = {
    CollaborationId = aws_cleanrooms_collaboration.clean_rooms_lab_analysis_collab.id
    RetainPolicy    = "Retain"
  }
}

resource "aws_cloudformation_stack" "collab_membership_account_2" {
  provider = aws.account_2

  name          = "aws-clean-rooms-lab-collab-membership-${random_string.uid.id}"
  template_body = file("${path.module}/templates/create-collaboration-membership.yaml")

  parameters = {
    CollaborationId    = aws_cleanrooms_collaboration.clean_rooms_lab_analysis_collab.id
    CreateResultConfig = "True"
    ResultBucketName   = data.terraform_remote_state.prepare_glue_database.outputs.query_result_bucket_account_2.id
    RetainPolicy       = "Delete"
  }
}

resource "aws_iam_role" "members_table_association_role" {
  name = "aws-clean-rooms-lab-members-table-association-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cleanrooms.amazonaws.com"
        }
        Condition = {
          StringLike = {
            "sts:ExternalId" = "arn:aws:*:*:*:dbuser:*/${aws_cloudformation_stack.collab_membership_account_2.outputs.MembershipId}*"
          }
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cleanrooms.amazonaws.com"
        }
        Condition = {
          "ForAnyValue:ArnEquals" = {
            "aws:SourceArn" = [
              "arn:aws:cleanrooms:*:${data.aws_caller_identity.account_1.account_id}:membership/${aws_cloudformation_stack.collab_membership_account_1.outputs.MembershipId}",
              "arn:aws:cleanrooms:*:${data.aws_caller_identity.account_2.account_id}:membership/${aws_cloudformation_stack.collab_membership_account_2.outputs.MembershipId}"
            ]
          }
        }
      },
    ]
  })

  inline_policy {
    name = "members_table_association_role_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "glue:GetDatabase",
            "glue:GetDatabases",
            "glue:GetTable",
            "glue:GetTables",
            "glue:GetPartition",
            "glue:GetPartitions",
            "glue:BatchGetPartition"
          ]
          Effect = "Allow"
          Resource = [
            "arn:aws:glue:*:${data.aws_caller_identity.account_1.account_id}:catalog",
            data.terraform_remote_state.prepare_glue_database.outputs.glue_database_account_1.arn,
            data.terraform_remote_state.prepare_glue_database.outputs.members_table.arn
          ]
        },
        {
          Action = [
            "glue:GetSchema",
            "glue:GetSchemaVersion"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = [
            "s3:GetBucketLocation",
            "s3:ListBucket"
          ]
          Effect   = "Allow"
          Resource = data.terraform_remote_state.prepare_glue_database.outputs.data_bucket_account_1.arn
          Condition = {
            "StringEquals" = {
              "s3:ResourceAccount" = data.aws_caller_identity.account_1.account_id
            }
          }
        },
        {
          Action = [
            "s3:GetObject"
          ]
          Effect   = "Allow"
          Resource = "${data.terraform_remote_state.prepare_glue_database.outputs.data_bucket_account_1.arn}/airline-loyalty-program/members/*"
          Condition = {
            "StringEquals" = {
              "s3:ResourceAccount" = data.aws_caller_identity.account_1.account_id
            }
          }
        }
      ]
    })
  }
}

# Sometime, the Clean Rooms collaboration cannot assume the IAM role if it's created too soon
# Adding this wait between creation of IAM role and table association
resource "time_sleep" "wait_before_members_table_association" {
  depends_on = [aws_iam_role.members_table_association_role]

  create_duration = "30s"
}

resource "aws_cloudformation_stack" "members_table_association" {
  depends_on = [time_sleep.wait_before_members_table_association]

  name          = "aws-clean-rooms-lab-members-table-association-${random_string.uid.id}"
  template_body = file("${path.module}/templates/create-table-association-account-01.yaml")

  parameters = {
    ConfiguredTableId = aws_cloudformation_stack.members_table.outputs.ConfiguredTableId
    MembershipId      = aws_cloudformation_stack.collab_membership_account_1.outputs.MembershipId
    RoleArn           = aws_iam_role.members_table_association_role.arn
  }
}

resource "aws_cloudformation_stack" "privacy_budget_template" {
  name          = "aws-clean-rooms-lab-privacy-budget-template-${random_string.uid.id}"
  template_body = file("${path.module}/templates/create-privacy-budget-template.yaml")

  parameters = {
    AutoRefresh        = "NONE"
    MembershipId       = aws_cloudformation_stack.collab_membership_account_1.outputs.MembershipId
    Epsilon            = 10
    UsersNoisePerQuery = 30
  }
}
