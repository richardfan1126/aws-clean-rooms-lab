"""Session 01: Collaboration Membership for Account 2"""
from aws_cdk import (
    Stack,
    aws_cleanrooms as cleanrooms,
    CfnOutput,
)
from constructs import Construct


class Session01Account2Stack(Stack):
    """
    Creates the membership for Account 2 in the Clean Rooms collaboration
    with result configuration
    """

    def __init__(
        self,
        scope: Construct,
        construct_id: str,
        collaboration_id: str,
        result_bucket_name: str,
        **kwargs
    ) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # ========================================
        # Membership for Account 2 with Result Config
        # ========================================
        membership_account_2 = cleanrooms.CfnMembership(
            self,
            "CollaborationMembershipAccount2",
            collaboration_identifier=collaboration_id,
            query_log_status="ENABLED",
            default_result_configuration=cleanrooms.CfnMembership.MembershipProtectedQueryResultConfigurationProperty(
                output_configuration=cleanrooms.CfnMembership.MembershipProtectedQueryOutputConfigurationProperty(
                    s3=cleanrooms.CfnMembership.ProtectedQueryS3OutputProperty(
                        bucket=result_bucket_name,
                        result_format="CSV",
                    )
                )
            ),
        )

        # Set deletion policy to DELETE (different from Account 1)
        membership_account_2.cfn_options.deletion_policy = "Delete"
        membership_account_2.cfn_options.update_replace_policy = "Delete"

        # ========================================
        # Outputs
        # ========================================
        CfnOutput(
            self,
            "MembershipIdAccount2Output",
            value=membership_account_2.attr_membership_identifier,
            description="Membership ID for Account 2",
        )
