output "data_bucket_account_1" {
  value = aws_s3_bucket.data_bucket_account_1
}

output "query_result_bucket_account_1" {
  value = aws_s3_bucket.query_result_bucket_account_1
}

output "data_bucket_account_2" {
  value = aws_s3_bucket.data_bucket_account_2
}

output "query_result_bucket_account_2" {
  value = aws_s3_bucket.query_result_bucket_account_2
}

output "glue_database_account_1" {
  value = aws_glue_catalog_database.database_account_1
}

output "glue_database_account_2" {
  value = aws_glue_catalog_database.database_account_2
}

output "members_table" {
  value = aws_glue_catalog_table.members_table
}

output "flight_history_table" {
  value = aws_glue_catalog_table.flight_history_table
}
