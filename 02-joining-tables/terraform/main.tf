locals {
  import_prev_state       = fileexists("${path.module}/../../01-create-simple-collaboration/terraform/terraform.tfstate")
  account_1_membership_id = local.import_prev_state ? data.terraform_remote_state.create_simple_collaboration[0].outputs.account_1_membership_id : var.account_1_membership_id
  account_2_membership_id = local.import_prev_state ? data.terraform_remote_state.create_simple_collaboration[0].outputs.account_2_membership_id : var.account_2_membership_id
}

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

data "terraform_remote_state" "create_simple_collaboration" {
  count = local.import_prev_state ? 1 : 0

  backend = "local"

  config = {
    path = "${path.module}/../../01-create-simple-collaboration/terraform/terraform.tfstate"
  }
}

resource "random_string" "uid" {
  length  = 4
  upper   = false
  special = false
}

resource "aws_cloudformation_stack" "members_join_table" {
  name          = "aws-clean-rooms-lab-members-join-table-${random_string.uid.id}"
  template_body = file("${path.module}/templates/create-members-join-table.yaml")

  parameters = {
    TableName        = "members_join"
    GlueDatabaseName = split(":", data.terraform_remote_state.prepare_glue_database.outputs.glue_database_account_1.id)[1]
    GlueTableName    = split(":", data.terraform_remote_state.prepare_glue_database.outputs.members_table.id)[2]
  }
}

resource "aws_iam_role" "members_join_table_association_role" {
  name = "aws-clean-rooms-lab-members-join-table-association-role"

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
            "sts:ExternalId" = "arn:aws:*:*:*:dbuser:*/${local.account_2_membership_id}*"
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
              "arn:aws:cleanrooms:*:${data.aws_caller_identity.account_1.account_id}:membership/${local.account_1_membership_id}",
              "arn:aws:cleanrooms:*:${data.aws_caller_identity.account_2.account_id}:membership/${local.account_2_membership_id}"
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

resource "aws_cloudformation_stack" "members_join_table_association" {
  name          = "aws-clean-rooms-lab-members-join-table-association-${random_string.uid.id}"
  template_body = file("${path.module}/templates/create-table-association.yaml")

  parameters = {
    TableAssociationName = "members_join"
    ConfiguredTableId    = aws_cloudformation_stack.members_join_table.outputs.ConfiguredTableId
    MembershipId         = local.account_1_membership_id
    RoleArn              = aws_iam_role.members_join_table_association_role.arn
  }
}

resource "aws_cloudformation_stack" "flight_history_table" {
  provider = aws.account_2

  name          = "aws-clean-rooms-lab-flight-history-join-table-${random_string.uid.id}"
  template_body = file("${path.module}/templates/create-flight-history-join-table.yaml")

  parameters = {
    TableName        = "flight_history"
    GlueDatabaseName = split(":", data.terraform_remote_state.prepare_glue_database.outputs.glue_database_account_2.id)[1]
    GlueTableName    = split(":", data.terraform_remote_state.prepare_glue_database.outputs.flight_history_table.id)[2]
  }
}

resource "aws_iam_role" "flight_history_table_association_role" {
  provider = aws.account_2

  name = "aws-clean-rooms-lab-flight-history-table-association-role"

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
            "sts:ExternalId" = "arn:aws:*:*:*:dbuser:*/${local.account_2_membership_id}*"
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
              "arn:aws:cleanrooms:*:${data.aws_caller_identity.account_1.account_id}:membership/${local.account_1_membership_id}",
              "arn:aws:cleanrooms:*:${data.aws_caller_identity.account_2.account_id}:membership/${local.account_2_membership_id}"
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

resource "aws_cloudformation_stack" "flight_history_table_association" {
  provider = aws.account_2

  name          = "aws-clean-rooms-lab-members-join-table-association-${random_string.uid.id}"
  template_body = file("${path.module}/templates/create-table-association.yaml")

  parameters = {
    TableAssociationName = "flight_history"
    ConfiguredTableId    = aws_cloudformation_stack.flight_history_table.outputs.ConfiguredTableId
    MembershipId         = local.account_2_membership_id
    RoleArn              = aws_iam_role.flight_history_table_association_role.arn
  }
}
