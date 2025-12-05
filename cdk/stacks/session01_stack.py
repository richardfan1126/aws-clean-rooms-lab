"""Session 01: Create Simple Collaboration Stack"""
from aws_cdk import (
    Stack,
    aws_cleanrooms as cleanrooms,
    aws_iam as iam,
    Duration,
    CfnOutput,
    Fn,
)
from constructs import Construct
import random
import string


class Session01Stack(Stack):
    """
    Creates a simple AWS Clean Rooms collaboration with aggregation rules:
    - Clean Rooms Collaboration
    - Configured Table with aggregation analysis rules
    - Membership for Account 1
    - IAM role for table association
    - Table association
    """

    def __init__(
        self,
        scope: Construct,
        construct_id: str,
        account_1_id: str,
        account_2_id: str,
        glue_database_name: str,
        glue_table_name: str,
        data_bucket_arn: str,
        **kwargs
    ) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # Generate a unique ID
        uid = ''.join(random.choices(string.ascii_lowercase + string.digits, k=4))

        # ========================================
        # Clean Rooms Collaboration
        # ========================================
        collaboration = cleanrooms.CfnCollaboration(
            self,
            "CleanRoomsLabCollaboration",
            name="clean_rooms_lab_collab_01",
            description="clean_rooms_lab_collab_01",
            creator_display_name="member-data-source",
            creator_member_abilities=[],
            query_log_status="ENABLED",
            members=[
                cleanrooms.CfnCollaboration.MemberSpecificationProperty(
                    account_id=account_2_id,
                    display_name="flight-data-store",
                    member_abilities=["CAN_QUERY", "CAN_RECEIVE_RESULTS"],
                )
            ],
        )

        # ========================================
        # Configured Table with Aggregation Rules
        # ========================================
        configured_table = cleanrooms.CfnConfiguredTable(
            self,
            "MembersAggregationTable",
            name="members_aggregation",
            analysis_method="DIRECT_QUERY",
            allowed_columns=[
                "city",
                "clv",
                "country",
                "education",
                "enrollment_month",
                "enrollment_type",
                "enrollment_year",
                "gender",
                "loyalty_card",
                "marital_status",
                "salary",
                "postal_code",
                "province",
                "loyalty_number",
            ],
            table_reference=cleanrooms.CfnConfiguredTable.TableReferenceProperty(
                glue=cleanrooms.CfnConfiguredTable.GlueTableReferenceProperty(
                    database_name=glue_database_name,
                    table_name=glue_table_name,
                )
            ),
            analysis_rules=[
                cleanrooms.CfnConfiguredTable.AnalysisRuleProperty(
                    type="AGGREGATION",
                    policy=cleanrooms.CfnConfiguredTable.ConfiguredTableAnalysisRulePolicyProperty(
                        v1=cleanrooms.CfnConfiguredTable.ConfiguredTableAnalysisRulePolicyV1Property(
                            aggregation=cleanrooms.CfnConfiguredTable.AnalysisRuleAggregationProperty(
                                aggregate_columns=[
                                    cleanrooms.CfnConfiguredTable.AggregateColumnProperty(
                                        column_names=["loyalty_number"],
                                        function="COUNT_DISTINCT",
                                    )
                                ],
                                dimension_columns=[
                                    "city",
                                    "clv",
                                    "country",
                                    "education",
                                    "enrollment_month",
                                    "enrollment_type",
                                    "enrollment_year",
                                    "gender",
                                    "loyalty_card",
                                    "marital_status",
                                    "salary",
                                    "postal_code",
                                    "province",
                                ],
                                join_columns=[],
                                scalar_functions=[],
                                output_constraints=[
                                    cleanrooms.CfnConfiguredTable.AggregationConstraintProperty(
                                        column_name="loyalty_number",
                                        minimum=100,
                                        type="COUNT_DISTINCT",
                                    )
                                ],
                            )
                        )
                    ),
                )
            ],
        )

        # ========================================
        # Membership for Account 1
        # ========================================
        membership_account_1 = cleanrooms.CfnMembership(
            self,
            "CollaborationMembershipAccount1",
            collaboration_identifier=collaboration.attr_collaboration_identifier,
            query_log_status="ENABLED",
        )

        # ========================================
        # IAM Role for Table Association
        # ========================================
        # Note: This role needs to be created after the membership to get the membership ID
        # We'll use a custom resource or wait for the membership to be created
        table_association_role = iam.Role(
            self,
            "MembersTableAssociationRole",
            role_name="aws-clean-rooms-lab-members-table-association-role",
            assumed_by=iam.ServicePrincipal("cleanrooms.amazonaws.com"),
            inline_policies={
                "members_table_association_role_policy": iam.PolicyDocument(
                    statements=[
                        iam.PolicyStatement(
                            effect=iam.Effect.ALLOW,
                            actions=[
                                "glue:GetDatabase",
                                "glue:GetDatabases",
                                "glue:GetTable",
                                "glue:GetTables",
                                "glue:GetPartition",
                                "glue:GetPartitions",
                                "glue:BatchGetPartition",
                            ],
                            resources=[
                                f"arn:aws:glue:*:{account_1_id}:catalog",
                                f"arn:aws:glue:*:{account_1_id}:database/{glue_database_name}",
                                f"arn:aws:glue:*:{account_1_id}:table/{glue_database_name}/{glue_table_name}",
                            ],
                        ),
                        iam.PolicyStatement(
                            effect=iam.Effect.ALLOW,
                            actions=[
                                "glue:GetSchema",
                                "glue:GetSchemaVersion",
                            ],
                            resources=["*"],
                        ),
                        iam.PolicyStatement(
                            effect=iam.Effect.ALLOW,
                            actions=[
                                "s3:GetBucketLocation",
                                "s3:ListBucket",
                            ],
                            resources=[data_bucket_arn],
                            conditions={
                                "StringEquals": {
                                    "s3:ResourceAccount": account_1_id
                                }
                            },
                        ),
                        iam.PolicyStatement(
                            effect=iam.Effect.ALLOW,
                            actions=["s3:GetObject"],
                            resources=[f"{data_bucket_arn}/airline-loyalty-program/members/*"],
                            conditions={
                                "StringEquals": {
                                    "s3:ResourceAccount": account_1_id
                                }
                            },
                        ),
                    ]
                )
            },
        )

        # Update assume role policy to include membership conditions
        # This needs to be done after membership is created
        table_association_role.assume_role_policy.add_statements(
            iam.PolicyStatement(
                effect=iam.Effect.ALLOW,
                principals=[iam.ServicePrincipal("cleanrooms.amazonaws.com")],
                actions=["sts:AssumeRole"],
                conditions={
                    "StringLike": {
                        "sts:ExternalId": f"arn:aws:*:*:*:dbuser:*/{membership_account_1.attr_membership_identifier}*"
                    }
                },
            ),
            iam.PolicyStatement(
                effect=iam.Effect.ALLOW,
                principals=[iam.ServicePrincipal("cleanrooms.amazonaws.com")],
                actions=["sts:AssumeRole"],
                conditions={
                    "ForAnyValue:ArnEquals": {
                        "aws:SourceArn": [
                            f"arn:aws:cleanrooms:*:{account_1_id}:membership/{membership_account_1.attr_membership_identifier}"
                        ]
                    }
                },
            ),
        )

        # Add dependency to ensure role is created after membership
        table_association_role.node.add_dependency(membership_account_1)

        # ========================================
        # Table Association
        # ========================================
        # Wait 30 seconds before creating table association (as in Terraform)
        table_association = cleanrooms.CfnConfiguredTableAssociation(
            self,
            "MembersTableAssociation",
            name="members",
            configured_table_identifier=configured_table.attr_configured_table_identifier,
            membership_identifier=membership_account_1.attr_membership_identifier,
            role_arn=table_association_role.role_arn,
        )

        # Add dependency to ensure proper order
        table_association.node.add_dependency(table_association_role)

        # ========================================
        # Outputs
        # ========================================
        CfnOutput(
            self,
            "CollaborationIdOutput",
            value=collaboration.attr_collaboration_identifier,
            description="Clean Rooms Collaboration ID",
        )

        CfnOutput(
            self,
            "MembershipIdAccount1Output",
            value=membership_account_1.attr_membership_identifier,
            description="Membership ID for Account 1",
        )

        CfnOutput(
            self,
            "ConfiguredTableIdOutput",
            value=configured_table.attr_configured_table_identifier,
            description="Configured Table ID",
        )
