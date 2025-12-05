#!/usr/bin/env python3
"""AWS Clean Rooms Lab CDK App"""
import os
from aws_cdk import App, Environment
from stacks.session00_stack import Session00Stack
from stacks.session00_account2_stack import Session00Account2Stack
from stacks.session01_stack import Session01Stack
from stacks.session01_account2_stack import Session01Account2Stack

app = App()

# Get account IDs and region from context or environment
# You can set these via cdk.context.json or command line:
# cdk deploy -c account_1_id=123456789012 -c account_2_id=098765432101
account_1_id = app.node.try_get_context("account_1_id") or os.environ.get("ACCOUNT_1_ID")
account_2_id = app.node.try_get_context("account_2_id") or os.environ.get("ACCOUNT_2_ID")
region = app.node.try_get_context("region") or os.environ.get("AWS_REGION") or "us-east-1"

# Generate a shared UID for bucket naming (4 characters)
# In production, you might want to manage this via SSM Parameter Store or similar
import random
import string
uid = ''.join(random.choices(string.ascii_lowercase + string.digits, k=4))

if not account_1_id or not account_2_id:
    raise ValueError(
        "Account IDs must be provided via context or environment variables.\n"
        "Use: cdk deploy -c account_1_id=123456789012 -c account_2_id=098765432101\n"
        "Or set ACCOUNT_1_ID and ACCOUNT_2_ID environment variables"
    )

# ========================================
# Session 00: Foundation Infrastructure
# ========================================

# Account 1 resources
session00_stack = Session00Stack(
    app,
    "Session00Stack",
    account_1_id=account_1_id,
    account_2_id=account_2_id,
    env=Environment(account=account_1_id, region=region),
    description="Session 00: Glue databases, S3 buckets, and data for Account 1",
)

# Account 2 resources (deploy with different profile)
session00_account2_stack = Session00Account2Stack(
    app,
    "Session00Account2Stack",
    account_2_id=account_2_id,
    uid=uid,
    env=Environment(account=account_2_id, region=region),
    description="Session 00: Glue databases, S3 buckets, and data for Account 2",
)

# ========================================
# Session 01: Simple Collaboration
# ========================================

# Get outputs from Session 00 for Session 01
# In CDK, we can reference resources directly from the stack instances
glue_database_name = "aws-clean-rooms-lab"
glue_table_name = "members"

session01_stack = Session01Stack(
    app,
    "Session01Stack",
    account_1_id=account_1_id,
    account_2_id=account_2_id,
    glue_database_name=glue_database_name,
    glue_table_name=glue_table_name,
    data_bucket_arn=f"arn:aws:s3:::{account_1_id}-aws-clean-rooms-lab-data-{uid}",
    env=Environment(account=account_1_id, region=region),
    description="Session 01: Simple collaboration with aggregation rules for Account 1",
)

# Add dependency on Session 00
session01_stack.add_dependency(session00_stack)

# Note: Session 01 Account 2 stack requires the collaboration ID from Session 01 Stack
# This needs to be deployed after Session 01 Stack
# Example deployment shown in README.md

# ========================================
# Session 02 and 03
# ========================================
# Session 02 (Joining Tables) and Session 03 (Differential Privacy)
# follow similar patterns to Session 01.
#
# For simplicity, the base stacks are provided here.
# You can extend the pattern by creating:
# - stacks/session02_aggregate_stack.py
# - stacks/session02_list_stack.py
# - stacks/session03_stack.py
#
# Each follows the same pattern:
# 1. Create Collaboration
# 2. Create Configured Table with Analysis Rules
# 3. Create Memberships
# 4. Create IAM Roles
# 5. Create Table Associations
#
# See README.md for detailed implementation guidance.

app.synth()
