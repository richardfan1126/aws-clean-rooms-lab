"""Session 00: Prepare Glue Database Stack for Account 2"""
from aws_cdk import (
    Stack,
    aws_s3 as s3,
    aws_glue as glue,
    aws_s3_deployment as s3deploy,
    RemovalPolicy,
    CfnOutput,
)
from constructs import Construct


class Session00Account2Stack(Stack):
    """
    Creates the foundational infrastructure for AWS Clean Rooms Lab in Account 2:
    - S3 buckets for data and query results
    - Glue database and flight_history table
    - Uploads flight history Parquet data
    """

    def __init__(
        self,
        scope: Construct,
        construct_id: str,
        account_2_id: str,
        uid: str,
        **kwargs
    ) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # ========================================
        # Account 2 Resources
        # ========================================

        # S3 Buckets for Account 2
        self.data_bucket_account_2 = s3.Bucket(
            self,
            "DataBucketAccount2",
            bucket_name=f"{account_2_id}-aws-clean-rooms-lab-data-{uid}",
            removal_policy=RemovalPolicy.DESTROY,
            auto_delete_objects=True,
        )

        self.query_result_bucket_account_2 = s3.Bucket(
            self,
            "QueryResultBucketAccount2",
            bucket_name=f"{account_2_id}-aws-clean-rooms-lab-result-{uid}",
            removal_policy=RemovalPolicy.DESTROY,
            auto_delete_objects=True,
        )

        # Upload flight history data to S3
        flight_history_deployment = s3deploy.BucketDeployment(
            self,
            "FlightHistoryDataDeployment",
            sources=[s3deploy.Source.asset("../dataset", exclude=["members.parquet"])],
            destination_bucket=self.data_bucket_account_2,
            destination_key_prefix="airline-loyalty-program/flight_history/",
        )

        # Glue Database for Account 2
        self.glue_database_account_2 = glue.CfnDatabase(
            self,
            "GlueDatabaseAccount2",
            catalog_id=account_2_id,
            database_input=glue.CfnDatabase.DatabaseInputProperty(
                name="aws-clean-rooms-lab",
                create_table_default_permissions=[
                    glue.CfnDatabase.PrincipalPrivilegesProperty(
                        permissions=["ALL"],
                        principal=glue.CfnDatabase.DataLakePrincipalProperty(
                            data_lake_principal_identifier="IAM_ALLOWED_PRINCIPALS"
                        ),
                    )
                ],
            ),
        )

        # Flight History Glue Table
        self.flight_history_table = glue.CfnTable(
            self,
            "FlightHistoryTable",
            catalog_id=account_2_id,
            database_name=self.glue_database_account_2.ref,
            table_input=glue.CfnTable.TableInputProperty(
                name="flight_history",
                storage_descriptor=glue.CfnTable.StorageDescriptorProperty(
                    location=f"s3://{self.data_bucket_account_2.bucket_name}/airline-loyalty-program/flight_history/",
                    input_format="org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat",
                    output_format="org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat",
                    serde_info=glue.CfnTable.SerdeInfoProperty(
                        serialization_library="org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
                    ),
                    columns=[
                        glue.CfnTable.ColumnProperty(name="loyalty_number", type="string"),
                        glue.CfnTable.ColumnProperty(name="year", type="int"),
                        glue.CfnTable.ColumnProperty(name="month", type="int"),
                        glue.CfnTable.ColumnProperty(name="flights_booked", type="int"),
                        glue.CfnTable.ColumnProperty(name="flights_with_companions", type="int"),
                        glue.CfnTable.ColumnProperty(name="total_flights", type="int"),
                        glue.CfnTable.ColumnProperty(name="distance", type="int"),
                        glue.CfnTable.ColumnProperty(name="points_accumulated", type="int"),
                        glue.CfnTable.ColumnProperty(name="points_redeemed", type="int"),
                        glue.CfnTable.ColumnProperty(name="dollar_cost_points_redeemed", type="int"),
                    ],
                ),
            ),
        )
        self.flight_history_table.add_dependency(self.glue_database_account_2)

        # Outputs for Account 2
        CfnOutput(
            self,
            "DataBucketAccount2Output",
            value=self.data_bucket_account_2.bucket_name,
            description="Account 2 Data Bucket Name",
            export_name=f"{self.stack_name}-DataBucketAccount2",
        )

        CfnOutput(
            self,
            "QueryResultBucketAccount2Output",
            value=self.query_result_bucket_account_2.bucket_name,
            description="Account 2 Query Result Bucket Name",
            export_name=f"{self.stack_name}-QueryResultBucketAccount2",
        )

        CfnOutput(
            self,
            "GlueDatabaseAccount2Output",
            value=self.glue_database_account_2.ref,
            description="Account 2 Glue Database Name",
            export_name=f"{self.stack_name}-GlueDatabaseAccount2",
        )

        CfnOutput(
            self,
            "FlightHistoryTableOutput",
            value=self.flight_history_table.ref,
            description="Flight History Table Name",
            export_name=f"{self.stack_name}-FlightHistoryTable",
        )
