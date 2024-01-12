resource "aws_s3_bucket" "query_result_bucket_account_2" {
  provider = aws.account_2

  bucket        = "${data.aws_caller_identity.account_2.account_id}-aws-clean-rooms-lab-result-${random_string.uid.id}"
  force_destroy = true
}

resource "aws_s3_bucket" "data_bucket_account_2" {
  provider = aws.account_2

  bucket        = "${data.aws_caller_identity.account_2.account_id}-aws-clean-rooms-lab-data-${random_string.uid.id}"
  force_destroy = true
}

resource "aws_s3_object" "flight_history_data" {
  provider = aws.account_2

  bucket = aws_s3_bucket.data_bucket_account_2.id
  key    = "airline-loyalty-program/flight_history/flight_history.json"
  source = "${path.module}/../dataset/flight_history.json"
}

resource "aws_glue_catalog_database" "database_account_2" {
  provider = aws.account_2

  name = "aws-clean-rooms-lab"

  create_table_default_permission {
    permissions = ["ALL"]

    principal {
      data_lake_principal_identifier = "IAM_ALLOWED_PRINCIPALS"
    }
  }
}

resource "aws_glue_catalog_table" "flight_history_table" {
  provider = aws.account_2

  name          = "flight_history"
  database_name = aws_glue_catalog_database.database_account_2.name

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.data_bucket_account_2.id}/airline-loyalty-program/flight_history/"
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
      name = "year"
      type = "int"
    }

    columns {
      name = "month"
      type = "int"
    }

    columns {
      name = "flights booked"
      type = "int"
    }

    columns {
      name = "flights with companions"
      type = "int"
    }

    columns {
      name = "total flights"
      type = "int"
    }

    columns {
      name = "distance"
      type = "int"
    }

    columns {
      name = "points accumulated"
      type = "int"
    }

    columns {
      name = "points redeemed"
      type = "int"
    }

    columns {
      name = "dollar cost points redeemed"
      type = "int"
    }
  }
}
