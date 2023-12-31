# AWS Clean Rooms Lab

This lab will walk you through the setup of AWS Clean Rooms and try its different features.

## Scenario

The dataset we use is a modified version of the Customer loyalty program data from Northern Lights Air (NLA), a fictitious airline based in Canada. The original dataset is downloaded from [Maven Analytics](https://mavenanalytics.io/data-playground)

In this lab, we will set up the loyalty program member and flight activity databases in 2 different AWS accounts.

By using AWS Clean Rooms, the lab will showcase how data analysts can utilize data sources from different entities to perform data analysis without compromising data privacy.

## Prerequisite

* 2 AWS accounts
* Admin access on each AWS account (Both console and API access)
* Terraform

### Setup your environment

To deploy resources efficiently, the Terraform templates in this lab will be using 2 AWS profiles named:

* `aws-clean-rooms-lab-account-1`

   This is the account hosting members' database.

* `aws-clean-rooms-lab-account-2`

   This is the account hosting the flight activity database.

You should follow [this AWS guideline](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html#cli-configure-files-format-profile) to set up your local environment and set up these 2 profiles using the admin credentials of each AWS accounts.

**You should setup the profiles with the exact names given above.**

## Sessions

0. [Prepare Glue database](https://github.com/richardfan1126/aws-clean-rooms-lab/tree/main/00-prepare-glue-database)

   This session is a Terraform stack for creating the AWS Glue databases, which we will use in the lab.
