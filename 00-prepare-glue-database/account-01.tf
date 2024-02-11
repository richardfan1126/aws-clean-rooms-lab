resource "aws_s3_bucket" "query_result_bucket_account_1" {
  bucket        = "${data.aws_caller_identity.account_1.account_id}-aws-clean-rooms-lab-result-${random_string.uid.id}"
  force_destroy = true
}

resource "aws_s3_bucket" "data_bucket_account_1" {
  bucket        = "${data.aws_caller_identity.account_1.account_id}-aws-clean-rooms-lab-data-${random_string.uid.id}"
  force_destroy = true
}

resource "aws_s3_object" "members_data" {
  bucket = aws_s3_bucket.data_bucket_account_1.id
  key    = "airline-loyalty-program/members/members.parquet"
  source = "${path.module}/../dataset/members.parquet"
}

resource "aws_glue_catalog_database" "database_account_1" {
  name = "aws-clean-rooms-lab"

  create_table_default_permission {
    permissions = ["ALL"]

    principal {
      data_lake_principal_identifier = "IAM_ALLOWED_PRINCIPALS"
    }
  }
}

resource "aws_glue_catalog_table" "members_table" {
  name          = "members"
  database_name = aws_glue_catalog_database.database_account_1.name

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.data_bucket_account_1.id}/airline-loyalty-program/members/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    columns {
      name = "loyalty_number"
      type = "string"
    }

    columns {
      name = "country"
      type = "string"
    }

    columns {
      name = "province"
      type = "string"
    }

    columns {
      name = "city"
      type = "string"
    }

    columns {
      name = "postal_code"
      type = "string"
    }

    columns {
      name = "gender"
      type = "string"
    }

    columns {
      name = "education"
      type = "string"
    }

    columns {
      name = "salary"
      type = "double"
    }

    columns {
      name = "marital_status"
      type = "string"
    }

    columns {
      name = "loyalty_card"
      type = "string"
    }

    columns {
      name = "clv"
      type = "double"
    }

    columns {
      name = "enrollment_type"
      type = "string"
    }

    columns {
      name = "enrollment_year"
      type = "int"
    }

    columns {
      name = "enrollment_month"
      type = "int"
    }
  }
}
