"""Session 03: Differential Privacy Stack"""
from aws_cdk import (
    Stack,
    aws_cleanrooms as cleanrooms,
    aws_iam as iam,
    CfnOutput,
)
from constructs import Construct
import random
import string


class Session03Stack(Stack):
    """
    Creates AWS Clean Rooms collaboration with differential privacy:
    - Clean Rooms Collaboration
    - Configured Table with CUSTOM analysis rules and differential privacy
    - Membership for Account 1
    - Privacy Budget Template
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
            "CleanRoomsLabCollaboration03",
            name="clean_rooms_lab_collab_03",
            description="clean_rooms_lab_collab_03",
            creator_display_name="member-data-source",
            creator_member_abilities=[],
            query_log_status="ENABLED",
            members=[
                cleanrooms.CfnCollaboration.MemberSpecificationProperty(
                    account_id=account_2_id,
                    display_name="data-consumer",
                    member_abilities=["CAN_QUERY", "CAN_RECEIVE_RESULTS"],
                )
            ],
        )

        # ========================================
        # Configured Table with CUSTOM Analysis Rules (Differential Privacy)
        # ========================================
        configured_table = cleanrooms.CfnConfiguredTable(
            self,
            "MembersTableWithDifferentialPrivacy",
            name="members",
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
                    type="CUSTOM",
                    policy=cleanrooms.CfnConfiguredTable.ConfiguredTableAnalysisRulePolicyProperty(
                        v1=cleanrooms.CfnConfiguredTable.ConfiguredTableAnalysisRulePolicyV1Property(
                            custom=cleanrooms.CfnConfiguredTable.AnalysisRuleCustomProperty(
                                allowed_analyses=["ANY_QUERY"],
                                allowed_analysis_providers=[account_2_id],
                                differential_privacy=cleanrooms.CfnConfiguredTable.DifferentialPrivacyProperty(
                                    columns=[
                                        cleanrooms.CfnConfiguredTable.DifferentialPrivacyColumnProperty(
                                            name="loyalty_number"
                                        )
                                    ]
                                ),
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
        # Privacy Budget Template
        # ========================================
        privacy_budget = cleanrooms.CfnPrivacyBudgetTemplate(
            self,
            "PrivacyBudgetTemplate",
            auto_refresh="NONE",
            membership_identifier=membership_account_1.attr_membership_identifier,
            privacy_budget_type="DIFFERENTIAL_PRIVACY",
            parameters=cleanrooms.CfnPrivacyBudgetTemplate.ParametersProperty(
                epsilon=10,
                users_noise_per_query=30,
            ),
        )

        privacy_budget.add_dependency(membership_account_1)

        # ========================================
        # IAM Role for Table Association
        # ========================================
        table_association_role = iam.Role(
            self,
            "MembersTableAssociationRole03",
            role_name="aws-clean-rooms-lab-members-table-association-role-03",
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

        # Update assume role policy
        table_association_role.assume_role_policy.add_statements(
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
            )
        )

        table_association_role.node.add_dependency(membership_account_1)

        # ========================================
        # Table Association
        # ========================================
        table_association = cleanrooms.CfnConfiguredTableAssociation(
            self,
            "MembersTableAssociation",
            name="members",
            configured_table_identifier=configured_table.attr_configured_table_identifier,
            membership_identifier=membership_account_1.attr_membership_identifier,
            role_arn=table_association_role.role_arn,
        )

        table_association.node.add_dependency(table_association_role)

        # ========================================
        # Outputs
        # ========================================
        CfnOutput(
            self,
            "CollaborationIdOutput",
            value=collaboration.attr_collaboration_identifier,
            description="Clean Rooms Collaboration ID (Session 03)",
        )

        CfnOutput(
            self,
            "MembershipIdAccount1Output",
            value=membership_account_1.attr_membership_identifier,
            description="Membership ID for Account 1 (Session 03)",
        )

        CfnOutput(
            self,
            "ConfiguredTableIdOutput",
            value=configured_table.attr_configured_table_identifier,
            description="Configured Table ID with Differential Privacy",
        )
