resource "aws_cleanrooms_collaboration" "clean_rooms_lab_analysis_collab_list" {
  name                     = "clean_rooms_lab_collab_02-list"
  description              = "clean_rooms_lab_collab_02-list"
  creator_member_abilities = []
  creator_display_name     = "member-data-source"
  query_log_status         = "ENABLED"

  member {
    account_id       = data.aws_caller_identity.account_2.account_id
    display_name     = "flight-data-store"
    member_abilities = ["CAN_QUERY", "CAN_RECEIVE_RESULTS"]
  }
}

resource "aws_cloudformation_stack" "collab_membership_account_1_list" {
  name          = "aws-clean-rooms-lab-collab-membership-list-${random_string.uid.id}"
  template_body = file("${path.module}/templates/create-collaboration-membership.yaml")

  parameters = {
    CollaborationId = aws_cleanrooms_collaboration.clean_rooms_lab_analysis_collab_list.id
  }
}

resource "aws_cloudformation_stack" "collab_membership_account_2_list" {
  provider = aws.account_2

  name          = "aws-clean-rooms-lab-collab-membership-list-${random_string.uid.id}"
  template_body = file("${path.module}/templates/create-collaboration-membership-with-query.yaml")

  parameters = {
    CollaborationId  = aws_cleanrooms_collaboration.clean_rooms_lab_analysis_collab_list.id
    ResultBucketName = data.terraform_remote_state.prepare_glue_database.outputs.query_result_bucket_account_2.id
  }
}

resource "aws_cloudformation_stack" "members_table_list" {
  name          = "aws-clean-rooms-lab-members-table-list-${random_string.uid.id}"
  template_body = file("${path.module}/templates/list/create-members-table.yaml")

  parameters = {
    TableName        = "members_list"
    GlueDatabaseName = split(":", data.terraform_remote_state.prepare_glue_database.outputs.glue_database_account_1.id)[1]
    GlueTableName    = split(":", data.terraform_remote_state.prepare_glue_database.outputs.members_table.id)[2]
  }
}

resource "aws_iam_role" "members_table_association_role_list" {
  name = "aws-clean-rooms-lab-members-table-association-role-list"

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
            "sts:ExternalId" = "arn:aws:*:*:*:dbuser:*/${aws_cloudformation_stack.collab_membership_account_2_list.outputs.MembershipId}*"
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
              "arn:aws:cleanrooms:*:${data.aws_caller_identity.account_1.account_id}:membership/${aws_cloudformation_stack.collab_membership_account_1_list.outputs.MembershipId}",
              "arn:aws:cleanrooms:*:${data.aws_caller_identity.account_2.account_id}:membership/${aws_cloudformation_stack.collab_membership_account_2_list.outputs.MembershipId}"
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

resource "aws_cloudformation_stack" "members_table_association_list" {
  name          = "aws-clean-rooms-lab-members-table-association-list-${random_string.uid.id}"
  template_body = file("${path.module}/templates/create-table-association.yaml")

  parameters = {
    TableAssociationName = "members"
    ConfiguredTableId    = aws_cloudformation_stack.members_table_list.outputs.ConfiguredTableId
    MembershipId         = aws_cloudformation_stack.collab_membership_account_1_list.outputs.MembershipId
    RoleArn              = aws_iam_role.members_table_association_role_list.arn
  }
}

resource "aws_cloudformation_stack" "flight_history_table_list" {
  provider = aws.account_2

  name          = "aws-clean-rooms-lab-flight-history-table-list-${random_string.uid.id}"
  template_body = file("${path.module}/templates/list/create-flight-history-table.yaml")

  parameters = {
    TableName        = "flight_history_list"
    GlueDatabaseName = split(":", data.terraform_remote_state.prepare_glue_database.outputs.glue_database_account_2.id)[1]
    GlueTableName    = split(":", data.terraform_remote_state.prepare_glue_database.outputs.flight_history_table.id)[2]
  }
}

resource "aws_iam_role" "flight_history_table_association_role_list" {
  provider = aws.account_2

  name = "aws-clean-rooms-lab-flight-history-table-association-role-list"

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
            "sts:ExternalId" = "arn:aws:*:*:*:dbuser:*/${aws_cloudformation_stack.collab_membership_account_2_list.outputs.MembershipId}*"
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
              "arn:aws:cleanrooms:*:${data.aws_caller_identity.account_1.account_id}:membership/${aws_cloudformation_stack.collab_membership_account_1_list.outputs.MembershipId}",
              "arn:aws:cleanrooms:*:${data.aws_caller_identity.account_2.account_id}:membership/${aws_cloudformation_stack.collab_membership_account_2_list.outputs.MembershipId}"
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
            "arn:aws:glue:*:${data.aws_caller_identity.account_2.account_id}:catalog",
            data.terraform_remote_state.prepare_glue_database.outputs.glue_database_account_2.arn,
            data.terraform_remote_state.prepare_glue_database.outputs.flight_history_table.arn
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
          Resource = data.terraform_remote_state.prepare_glue_database.outputs.data_bucket_account_2.arn
          Condition = {
            "StringEquals" = {
              "s3:ResourceAccount" = data.aws_caller_identity.account_2.account_id
            }
          }
        },
        {
          Action = [
            "s3:GetObject"
          ]
          Effect   = "Allow"
          Resource = "${data.terraform_remote_state.prepare_glue_database.outputs.data_bucket_account_2.arn}/airline-loyalty-program/flight_history/*"
          Condition = {
            "StringEquals" = {
              "s3:ResourceAccount" = data.aws_caller_identity.account_2.account_id
            }
          }
        }
      ]
    })
  }
}

resource "aws_cloudformation_stack" "flight_history_table_association_list" {
  provider = aws.account_2

  name          = "aws-clean-rooms-lab-flight-history-table-association-list-${random_string.uid.id}"
  template_body = file("${path.module}/templates/create-table-association.yaml")

  parameters = {
    TableAssociationName = "flight_history"
    ConfiguredTableId    = aws_cloudformation_stack.flight_history_table_list.outputs.ConfiguredTableId
    MembershipId         = aws_cloudformation_stack.collab_membership_account_2_list.outputs.MembershipId
    RoleArn              = aws_iam_role.flight_history_table_association_role_list.arn
  }
}
