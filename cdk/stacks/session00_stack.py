"""Session 00: Prepare Glue Database Stack"""
from aws_cdk import (
    Stack,
    aws_s3 as s3,
    aws_glue as glue,
    aws_s3_deployment as s3deploy,
    aws_iam as iam,
    RemovalPolicy,
    CfnOutput,
)
from constructs import Construct
import random
import string


class Session00Stack(Stack):
    """
    Creates the foundational infrastructure for AWS Clean Rooms Lab:
    - S3 buckets for data and query results (Account 1 and Account 2)
    - Glue databases and tables
    - Uploads sample Parquet data
    """

    def __init__(
        self,
        scope: Construct,
        construct_id: str,
        account_1_id: str,
        account_2_id: str,
        **kwargs
    ) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # Generate a unique ID for bucket names (4 characters)
        uid = ''.join(random.choices(string.ascii_lowercase + string.digits, k=4))

        # ========================================
        # Account 1 Resources
        # ========================================

        # S3 Buckets for Account 1
        self.data_bucket_account_1 = s3.Bucket(
            self,
            "DataBucketAccount1",
            bucket_name=f"{account_1_id}-aws-clean-rooms-lab-data-{uid}",
            removal_policy=RemovalPolicy.DESTROY,
            auto_delete_objects=True,
        )

        self.query_result_bucket_account_1 = s3.Bucket(
            self,
            "QueryResultBucketAccount1",
            bucket_name=f"{account_1_id}-aws-clean-rooms-lab-result-{uid}",
            removal_policy=RemovalPolicy.DESTROY,
            auto_delete_objects=True,
        )

        # Upload members data to S3
        members_deployment = s3deploy.BucketDeployment(
            self,
            "MembersDataDeployment",
            sources=[s3deploy.Source.asset("../dataset", exclude=["flight_history_*.parquet"])],
            destination_bucket=self.data_bucket_account_1,
            destination_key_prefix="airline-loyalty-program/members/",
        )

        # Glue Database for Account 1
        self.glue_database_account_1 = glue.CfnDatabase(
            self,
            "GlueDatabaseAccount1",
            catalog_id=account_1_id,
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

        # Members Glue Table
        self.members_table = glue.CfnTable(
            self,
            "MembersTable",
            catalog_id=account_1_id,
            database_name=self.glue_database_account_1.ref,
            table_input=glue.CfnTable.TableInputProperty(
                name="members",
                storage_descriptor=glue.CfnTable.StorageDescriptorProperty(
                    location=f"s3://{self.data_bucket_account_1.bucket_name}/airline-loyalty-program/members/",
                    input_format="org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat",
                    output_format="org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat",
                    serde_info=glue.CfnTable.SerdeInfoProperty(
                        serialization_library="org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
                    ),
                    columns=[
                        glue.CfnTable.ColumnProperty(name="loyalty_number", type="string"),
                        glue.CfnTable.ColumnProperty(name="country", type="string"),
                        glue.CfnTable.ColumnProperty(name="province", type="string"),
                        glue.CfnTable.ColumnProperty(name="city", type="string"),
                        glue.CfnTable.ColumnProperty(name="postal_code", type="string"),
                        glue.CfnTable.ColumnProperty(name="gender", type="string"),
                        glue.CfnTable.ColumnProperty(name="education", type="string"),
                        glue.CfnTable.ColumnProperty(name="salary", type="double"),
                        glue.CfnTable.ColumnProperty(name="marital_status", type="string"),
                        glue.CfnTable.ColumnProperty(name="loyalty_card", type="string"),
                        glue.CfnTable.ColumnProperty(name="clv", type="double"),
                        glue.CfnTable.ColumnProperty(name="enrollment_type", type="string"),
                        glue.CfnTable.ColumnProperty(name="enrollment_year", type="int"),
                        glue.CfnTable.ColumnProperty(name="enrollment_month", type="int"),
                    ],
                ),
            ),
        )
        self.members_table.add_dependency(self.glue_database_account_1)

        # Outputs for Account 1
        CfnOutput(
            self,
            "DataBucketAccount1Output",
            value=self.data_bucket_account_1.bucket_name,
            description="Account 1 Data Bucket Name",
            export_name=f"{self.stack_name}-DataBucketAccount1",
        )

        CfnOutput(
            self,
            "QueryResultBucketAccount1Output",
            value=self.query_result_bucket_account_1.bucket_name,
            description="Account 1 Query Result Bucket Name",
            export_name=f"{self.stack_name}-QueryResultBucketAccount1",
        )

        CfnOutput(
            self,
            "GlueDatabaseAccount1Output",
            value=self.glue_database_account_1.ref,
            description="Account 1 Glue Database Name",
            export_name=f"{self.stack_name}-GlueDatabaseAccount1",
        )

        CfnOutput(
            self,
            "MembersTableOutput",
            value=self.members_table.ref,
            description="Members Table Name",
            export_name=f"{self.stack_name}-MembersTable",
        )
