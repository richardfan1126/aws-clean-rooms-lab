# Prepare Glue database

This session is to create the AWS Glue databases, which we can use in the lab.

## Setup

This session is not part of the lab. You just need to deploy the Terraform stack and everything will be setup.

1. Make sure you have set up your local environment correctly. [See instruction](/README.md#setup-your-environment)

1. Run the following scripts to deploy resources

   ```bash
   cd 00-prepare-glue-database/
   terraform init
   terraform apply -auto-approve
   ```

## Exercise

1. After deploying the stack, login to the S3 console.

   You will see 2 buckets, one is for storing the data and the other one for storing the query result.

   ![](/images/00-prepare-glue-database/01.png)

   Open the data bucket, you will see a JSON file, which is the data we will be playing with in this lab.

   ![](/images/00-prepare-glue-database/02.png)

1. Go to the Amazon Athena console, you will see a new database `aws-clean-room-lab` was created.

   Run some SQL query and explore the sample data.

   ![](/images/00-prepare-glue-database/03.png)