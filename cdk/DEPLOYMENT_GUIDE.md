# AWS Clean Rooms Lab - CDK Deployment Guide

This guide provides detailed instructions for deploying the AWS Clean Rooms Lab infrastructure using AWS CDK.

## Prerequisites

1. **AWS Accounts**: You need two AWS accounts configured
2. **AWS CLI**: Install and configure AWS CLI with named profiles
3. **Node.js**: Required for AWS CDK CLI (Node 18.x or later)
4. **Python**: Python 3.8 or later
5. **AWS CDK**: Install globally with `npm install -g aws-cdk`

## Setup AWS Profiles

Configure two AWS profiles in `~/.aws/credentials` and `~/.aws/config`:

```ini
# ~/.aws/credentials
[aws-clean-rooms-lab-account-1]
aws_access_key_id = YOUR_ACCOUNT_1_ACCESS_KEY
aws_secret_access_key = YOUR_ACCOUNT_1_SECRET_KEY

[aws-clean-rooms-lab-account-2]
aws_access_key_id = YOUR_ACCOUNT_2_ACCESS_KEY
aws_secret_access_key = YOUR_ACCOUNT_2_SECRET_KEY

# ~/.aws/config
[profile aws-clean-rooms-lab-account-1]
region = us-east-1
output = json

[profile aws-clean-rooms-lab-account-2]
region = us-east-1
output = json
```

## Initial Setup

1. Navigate to the CDK directory:
```bash
cd cdk
```

2. Create and activate a Python virtual environment:
```bash
python3 -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
```

3. Install Python dependencies:
```bash
pip install -r requirements.txt
```

4. Get your AWS account IDs:
```bash
AWS_ACCOUNT_1=$(aws sts get-caller-identity --profile aws-clean-rooms-lab-account-1 --query Account --output text)
AWS_ACCOUNT_2=$(aws sts get-caller-identity --profile aws-clean-rooms-lab-account-2 --query Account --output text)

echo "Account 1: $AWS_ACCOUNT_1"
echo "Account 2: $AWS_ACCOUNT_2"
```

5. Bootstrap CDK in both accounts (only needed once per account/region):
```bash
cdk bootstrap aws://$AWS_ACCOUNT_1/us-east-1 --profile aws-clean-rooms-lab-account-1
cdk bootstrap aws://$AWS_ACCOUNT_2/us-east-1 --profile aws-clean-rooms-lab-account-2
```

## Deployment Steps

### Session 00: Foundation Infrastructure

Deploy the foundational Glue databases and S3 buckets in both accounts:

```bash
# Deploy to Account 1
cdk deploy Session00Stack \
  --profile aws-clean-rooms-lab-account-1 \
  -c account_1_id=$AWS_ACCOUNT_1 \
  -c account_2_id=$AWS_ACCOUNT_2

# Deploy to Account 2
cdk deploy Session00Account2Stack \
  --profile aws-clean-rooms-lab-account-2 \
  -c account_1_id=$AWS_ACCOUNT_1 \
  -c account_2_id=$AWS_ACCOUNT_2
```

**What this creates:**
- S3 buckets for data and query results in both accounts
- Glue databases in both accounts
- Glue tables (members in Account 1, flight_history in Account 2)
- Uploads Parquet data files to S3

### Session 01: Simple Collaboration

Deploy the Clean Rooms collaboration with aggregation rules:

```bash
# Deploy collaboration and Account 1 membership
cdk deploy Session01Stack \
  --profile aws-clean-rooms-lab-account-1 \
  -c account_1_id=$AWS_ACCOUNT_1 \
  -c account_2_id=$AWS_ACCOUNT_2

# Get the collaboration ID from the output
COLLAB_ID_01=$(aws cloudformation describe-stacks \
  --stack-name Session01Stack \
  --profile aws-clean-rooms-lab-account-1 \
  --query 'Stacks[0].Outputs[?OutputKey==`CollaborationIdOutput`].OutputValue' \
  --output text)

# Get the query result bucket name for Account 2
RESULT_BUCKET_ACCOUNT_2=$(aws cloudformation describe-stacks \
  --stack-name Session00Account2Stack \
  --profile aws-clean-rooms-lab-account-2 \
  --query 'Stacks[0].Outputs[?OutputKey==`QueryResultBucketAccount2Output`].OutputValue' \
  --output text)

# Deploy Account 2 membership
# Note: You'll need to manually deploy this after Session01Stack
# or update app.py to include session01_account2_stack with parameters
```

**What this creates:**
- Clean Rooms Collaboration with aggregation analysis rules
- Configured table for members with COUNT_DISTINCT aggregation
- Membership for both accounts
- IAM role for table association
- Table association linking the configured table to the membership

### Session 03: Differential Privacy

Deploy the differential privacy collaboration:

```bash
# Deploy collaboration with differential privacy
cdk deploy Session03Stack \
  --profile aws-clean-rooms-lab-account-1 \
  -c account_1_id=$AWS_ACCOUNT_1 \
  -c account_2_id=$AWS_ACCOUNT_2

# Get the collaboration ID
COLLAB_ID_03=$(aws cloudformation describe-stacks \
  --stack-name Session03Stack \
  --profile aws-clean-rooms-lab-account-1 \
  --query 'Stacks[0].Outputs[?OutputKey==`CollaborationIdOutput`].OutputValue' \
  --output text)

# Deploy Account 2 membership (similar to Session 01)
```

**What this creates:**
- Clean Rooms Collaboration with CUSTOM analysis rules
- Differential privacy on loyalty_number column
- Privacy budget template (epsilon=10, users_noise_per_query=30)
- Configured table with ANY_QUERY allowed analysis
- Membership for both accounts with appropriate permissions

## Session 02: Joining Tables

Session 02 creates TWO separate collaborations (aggregate and list) with more complex join rules. This follows the same pattern as Session 01 and 03, but creates:

1. **Aggregate Collaboration**: Enables joining with aggregate functions (AVG, SUM, COUNT_DISTINCT)
2. **List Collaboration**: Allows more flexible queries with list analysis rules

To implement Session 02, you would create:
- `stacks/session02_aggregate_stack.py` (similar to Session01Stack but with join rules)
- `stacks/session02_list_stack.py` (similar to Session01Stack but with LIST analysis rules)
- `stacks/session02_account2_aggregate_stack.py`
- `stacks/session02_account2_list_stack.py`

The key differences are in the analysis rules configuration:
- **Aggregate**: Include `join_columns`, `join_required`, and additional aggregate functions
- **List**: Use type="LIST" with appropriate join columns

## Useful Commands

```bash
# List all stacks
cdk ls

# View the CloudFormation template for a stack
cdk synth Session00Stack

# Show differences between deployed stack and local code
cdk diff Session00Stack --profile aws-clean-rooms-lab-account-1

# Destroy a stack
cdk destroy Session01Stack --profile aws-clean-rooms-lab-account-1
```

## Troubleshooting

### IAM Role Assumption Issues
If you see errors about Clean Rooms not being able to assume IAM roles, the 30-second wait in the code should help. If issues persist, manually wait before deploying table associations.

### Cross-Account Permissions
Ensure both AWS accounts have the necessary permissions to create Clean Rooms collaborations and that they can share data appropriately.

### S3 Bucket Names
Bucket names must be globally unique. The code generates random suffixes, but you may need to adjust if names conflict.

### Glue Table Not Found
Ensure Session 00 stacks are fully deployed before deploying Session 01, 02, or 03.

## Clean Up

To remove all resources:

```bash
# Destroy in reverse order
cdk destroy Session03Account2Stack --profile aws-clean-rooms-lab-account-2
cdk destroy Session03Stack --profile aws-clean-rooms-lab-account-1

cdk destroy Session01Account2Stack --profile aws-clean-rooms-lab-account-2
cdk destroy Session01Stack --profile aws-clean-rooms-lab-account-1

cdk destroy Session00Account2Stack --profile aws-clean-rooms-lab-account-2
cdk destroy Session00Stack --profile aws-clean-rooms-lab-account-1
```

## Cost Considerations

- AWS Clean Rooms has costs based on query volume and data scanned
- S3 storage costs apply for data and query results
- Glue catalog has minimal costs
- Remember to clean up resources when done with the lab

## Next Steps

After deploying the infrastructure:
1. Navigate to the AWS Clean Rooms console in Account 2
2. Accept the collaboration invitation
3. Run queries to test the privacy-preserving data collaboration
4. Review query results in the S3 result buckets

## Support

For issues or questions:
- Check the main README.md
- Review AWS Clean Rooms documentation
- Check CloudFormation stack events for deployment errors
