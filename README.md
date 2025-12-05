# AWS Clean Rooms Lab

This lab will walk you through the setup of AWS Clean Rooms and try its different features.

## Scenario

The dataset we use is a modified version of the Customer loyalty program data from Northern Lights Air (NLA), a fictitious airline based in Canada. The original dataset is downloaded from [Maven Analytics](https://mavenanalytics.io/data-playground)

In this lab, we will set up the loyalty program member and flight activity databases in 2 different AWS accounts.

By using AWS Clean Rooms, the lab will showcase how data analysts can utilize data sources from different entities to perform data analysis without compromising data privacy.

## Prerequisite

* 2 AWS accounts
* Admin access on each AWS account (Both console and API access)
* **Infrastructure as Code Tool** - Choose one:
  * **Terraform** (original implementation in session directories)
  * **AWS CDK** (AWS-native implementation in `/cdk` directory) - **NEW!**

## Deployment Options

This lab supports two infrastructure deployment methods:

### Option 1: Terraform (Original)

The Terraform templates are located in each session directory (`00-prepare-glue-database`, `01-create-simple-collaboration`, etc.). Follow the session-specific README files for Terraform deployment instructions.

### Option 2: AWS CDK (AWS-Native)

**NEW:** A complete AWS CDK implementation is available in the `/cdk` directory. This provides an AWS-native approach using Python.

**Benefits of CDK:**
- Type-safe infrastructure code
- Better integration with AWS services
- No need for separate CloudFormation templates
- More programmatic control

**To use CDK:**
1. Navigate to the `/cdk` directory
2. Follow the setup instructions in [`/cdk/README.md`](/cdk/README.md)
3. See the comprehensive [`/cdk/DEPLOYMENT_GUIDE.md`](/cdk/DEPLOYMENT_GUIDE.md) for deployment steps

### Setup your environment

Both Terraform and CDK deployments use 2 AWS profiles named:

* `aws-clean-rooms-lab-account-1`

   This is the account hosting members' database.

* `aws-clean-rooms-lab-account-2`

   This is the account hosting the flight activity database.

You should follow [this AWS guideline](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html#cli-configure-files-format-profile) to set up your local environment and set up these 2 profiles using the admin credentials of each AWS accounts.

**You should setup the profiles with the exact names given above.**

## Terminologies

Complete list of terminologies in AWS documentation: [Link](https://docs.aws.amazon.com/clean-rooms/latest/userguide/glossary.html)

The following are some terminologies we will use in this lab.

* **Collaboration**

   This is the most fundamental resource in AWS Clean Rooms.

   To start working on AWS Clean Rooms, one AWS account will create a collaboration and invite other accounts to join. All other resources required for analysis collaboration will be created under the collaboration.

* **Membership**

   When the AWS account joins a collaboration, a membership will link the account and the collaboration.

   This is important because when a data provider grants data access to its data, it's granted to AWS Clean Rooms on behalf of the membership.

* **Configured Table**

   Configured table represents an AWS Glue table inside AWS Clean Rooms.

   We can set analysis rules on each configured table to restrict data usage over it.

* **Analysis Rule**

   Analysis rule is the restriction, which we can configure, over what and how queries can be performed over a configured table.

## Sessions

0. **[Prepare Glue database](/00-prepare-glue-database)**

   This session is to create the AWS Glue databases, which we can use in the lab.

1. **[Simple Collaboration](/01-create-simple-collaboration)**

   In this session, we will create our first AWS Clean Rooms collaboration with a simple configured table.

1. **[Joining data from different data sources](/02-joining-tables)**

   In this session, we will use AWS Clean Rooms to join multiple tables from different accounts.

1. **[Differential Privacy](/03-differential-privacy)**

   In this session, we will explore AWS Clean Rooms Differential Privacy and experience how differential privacy can be applied to data collaboration.

1. **Cryptographic Computing for Clean Rooms (C3R)**

   *TBC*
