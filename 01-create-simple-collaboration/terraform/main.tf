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

resource "aws_cleanrooms_collaboration" "clean_rooms_lab_analysis_collab" {
  name                     = "clean_rooms_lab_collab_01"
  description              = "clean_rooms_lab_collab_01"
  creator_member_abilities = []
  creator_display_name     = "member-data-source"
  query_log_status         = "ENABLED"

  member {
    account_id       = data.aws_caller_identity.account_2.account_id
    display_name     = "flight-data-store"
    member_abilities = ["CAN_QUERY", "CAN_RECEIVE_RESULTS"]
  }
}

resource "awscc_cleanrooms_configured_table" "members_table" {
  name            = "members_aggregation"
  analysis_method = "DIRECT_QUERY"
  table_reference = {
    glue = {
      database_name = split(":", data.terraform_remote_state.prepare_glue_database.outputs.glue_database_account_1.id)[1]
      table_name    = split(":", data.terraform_remote_state.prepare_glue_database.outputs.members_table.id)[2]
    }
  }

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
    "province",
    "loyalty number"
  ]

  analysis_rules = [
    {
      type = "AGGREGATION"
      policy = {
        v1 = {
          aggregation = {
            aggregate_columns = [
              {
                function = "COUNT_DISTINCT"
                column_names = [
                  "loyalty number"
                ]
              }
            ]
            dimension_columns = [
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
            join_columns = []
            output_constraints = [
              {
                column_name = "loyalty number"
                minimum     = 100
                type        = "COUNT_DISTINCT"
              }
            ]
            scalar_functions = []
          }
        }
      }
    }
  ]
}

resource "awscc_cleanrooms_membership" "collab_membership_account_1" {
  collaboration_identifier = aws_cleanrooms_collaboration.clean_rooms_lab_analysis_collab.id
  query_log_status         = "ENABLED"
}

resource "awscc_cleanrooms_membership" "collab_membership_account_2" {
  provider = awscc.account_2

  collaboration_identifier = aws_cleanrooms_collaboration.clean_rooms_lab_analysis_collab.id
  query_log_status         = "ENABLED"
  default_result_configuration = {
    output_configuration = {
      s3 = {
        bucket        = data.terraform_remote_state.prepare_glue_database.outputs.query_result_bucket_account_2.id
        result_format = "CSV"
      }
    }
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
            "sts:ExternalId" = "arn:aws:*:*:*:dbuser:*/${awscc_cleanrooms_membership.collab_membership_account_2.id}*"
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
              "arn:aws:cleanrooms:*:${data.aws_caller_identity.account_1.account_id}:membership/${awscc_cleanrooms_membership.collab_membership_account_1.id}",
              "arn:aws:cleanrooms:*:${data.aws_caller_identity.account_2.account_id}:membership/${awscc_cleanrooms_membership.collab_membership_account_2.id}"
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

resource "awscc_cleanrooms_configured_table_association" "members_table_association" {
  name                        = "members"
  configured_table_identifier = awscc_cleanrooms_configured_table.members_table.configured_table_identifier
  membership_identifier       = awscc_cleanrooms_membership.collab_membership_account_1.id
  role_arn                    = aws_iam_role.members_table_association_role.arn
}
