resource "aws_s3_bucket" "query_result_bucket_account_1" {
  bucket = "${data.aws_caller_identity.account_1.account_id}-aws-clean-rooms-lab-result-${random_string.uid.id}"
}

resource "aws_s3_bucket" "data_bucket_account_1" {
  bucket = "${data.aws_caller_identity.account_1.account_id}-aws-clean-rooms-lab-data-${random_string.uid.id}"
}

resource "aws_s3_object" "members_data" {
  bucket = aws_s3_bucket.data_bucket_account_1.id
  key    = "airline-loyalty-program/members/members.json"
  source = "${path.module}/../dataset/members.json"
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
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"
    }

    columns {
      name = "loyalty number"
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
      name = "postal code"
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
      type = "float"
    }

    columns {
      name = "marital status"
      type = "string"
    }

    columns {
      name = "loyalty card"
      type = "string"
    }

    columns {
      name = "clv"
      type = "float"
    }

    columns {
      name = "enrollment type"
      type = "string"
    }

    columns {
      name = "enrollment year"
      type = "int"
    }

    columns {
      name = "enrollment month"
      type = "int"
    }
  }
}
