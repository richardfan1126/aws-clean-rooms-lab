# AWS Clean Rooms Lab - CDK

This directory contains the AWS CDK (Cloud Development Kit) infrastructure code for the AWS Clean Rooms Lab.

## Prerequisites

- Python 3.8 or later
- AWS CDK CLI installed (`npm install -g aws-cdk`)
- AWS credentials configured for both accounts
- Python virtual environment recommended

## Setup

1. Create and activate a Python virtual environment:
```bash
python3 -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Configure AWS profiles in `~/.aws/credentials` and `~/.aws/config`:
   - `aws-clean-rooms-lab-account-1`
   - `aws-clean-rooms-lab-account-2`

## Deployment

The lab is organized into sessions that should be deployed in order:

### Session 00: Prepare Glue Database
```bash
cdk deploy Session00Stack --profile aws-clean-rooms-lab-account-1
```

### Session 01: Create Simple Collaboration
```bash
cdk deploy Session01Stack --profile aws-clean-rooms-lab-account-1
```

### Session 02: Joining Tables
```bash
cdk deploy Session02AggregateStack --profile aws-clean-rooms-lab-account-1
cdk deploy Session02ListStack --profile aws-clean-rooms-lab-account-1
```

### Session 03: Differential Privacy
```bash
cdk deploy Session03Stack --profile aws-clean-rooms-lab-account-1
```

## Deploy All Stacks
```bash
cdk deploy --all --profile aws-clean-rooms-lab-account-1
```

## Useful Commands

- `cdk ls` - List all stacks
- `cdk synth` - Synthesize CloudFormation templates
- `cdk diff` - Compare deployed stack with current state
- `cdk destroy` - Destroy stacks

## Stack Dependencies

- Session 01, 02, and 03 depend on Session 00 being deployed first
- Session 00 creates the foundational Glue databases and S3 buckets
