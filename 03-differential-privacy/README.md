# Differential Privacy

In this session, we will explore [AWS Clean Rooms Differential Privacy](https://docs.aws.amazon.com/clean-rooms/latest/userguide/differential-privacy.html) and experience how differential privacy can be applied to data collaboration.

## What is Differential Privacy?

Differential Privacy is a statistical measurement of how much an individual’s privacy is lost when exposing the data.

It can be used in data collaboration to help data owners measure and limit privacy loss when sharing data with other parties.

To learn more about Differential Privacy, please read my blog post: [What You Need to Know About the NIST Guideline on Differential Privacy](https://blog.richardfan.xyz/2024/02/21/what-you-need-to-know-about-the-nist-guideline-on-differential-privacy.html)

## Scenario

In this session, we have 2 parties:

* Member data source (i.e., account 1)

* Data consumer (i.e., account 2)

The data consumer wants to run queries on the member database from the member data source company to gain insight into member distributions by different attributes.

However, the member data source company wants to prevent any individual from being identified in this data collaboration.

Although we can use the AWS Clean Rooms Aggregate analysis rule to limit the query capability, we cannot prevent the data consumer from running multiple targeted queries to identify an individual.

If we allow the data consumers to run unlimited queries, they can probably identify an individual from a small group by repeating the queries and comparing each result.

```sql
SELECT COUNT(DISTINCT "loyalty_number")
FROM "members";
-- Result: 300


SELECT COUNT(DISTINCT "loyalty_number")
FROM "members"
WHERE "city" <> 'A Very Small Town';
-- Result: 280
```

In the above example, if the data consumers compare the results of the 2 queries, they can find that there are 20 members from a small town.

If they keep using the same strategy on other attributes (e.g., `marital_status`, `education`, `gender`, etc.), they will likely identify whether an individual is in the member database.

To prevent this, the member data source company can utilize Differential Privacy to limit the total privacy loss from a data collaboration.

## Setup

AWS Clean Rooms Differential Privacy is still in preview, and there is no CloudFormation or Terraform module for it yet.

So, in this session, only manual deployment is available.

### Manual Deployment

1. Complete [**0. Prepare Glue database**](/00-prepare-glue-database) deployment.

1. Login to the AWS Clean Rooms console using the `aws-clean-rooms-lab-account-1` credential.

   1. Click on **Create collaboration**
   
      ![](/images/03-differential-privacy/01.png)

      1. Input the following details:

         * **Name**: `clean_rooms_lab_collab_03`

         * **Description**: `clean_rooms_lab_collab_03`

         * **Member 1 display name**: `member-data-source`

         * **Member 2 display name**: `data-consumer`

         * **Member 2 AWS account ID**: *(The account ID of your second AWS account)*

         * **Member abilities**:

            * **Run queries**: `data-consumer` (i.e. Account 2)

            * **Receive results**: `Same as who runs queries`

         * **Payment configuration**:

            * **Pay for queries**: `Same as who runs queries`

         * **Support query logging in this collaboration**: Checked

         ![](/images/03-differential-privacy/02.png)

         ![](/images/03-differential-privacy/03.png)

      1. Click **Next** to **Configure membership** page.

         Select **Yes, join by creating membership now** and **Turn on Query logging**, then click **Next**.

         ![](/images/03-differential-privacy/04.png)

      1. Review the details, then click **Create collaboration and membership**.

         ![](/images/03-differential-privacy/05.png)

   1. Click on **Configured tables** on the nav menu, then click **Configure new table**.

      ![](/images/03-differential-privacy/06.png)

      1. Input the following details, then click **Configure new table**:

         * **Database**: `aws-clean-rooms-lab`

         * **Table**: `members`

         * **Which columns do you want to allow in collaborations?**: `All columns`

         * **Configured table Name**: `members`

         ![](/images/03-differential-privacy/07.png)

      1. There is a warning saying **This table is not configure for querying**.

         Click **Configure analysis rule**.

         ![](/images/03-differential-privacy/08.png)

      1. Choose `Custom` for **Analysis rule type** and `Guided flow` for **Creation method**, then click **Next**.

         ![](/images/03-differential-privacy/09.png)

      1. In the **Set differential privacy** page, input the following details, then click **Next**:

         * **Differential privacy**: `Turn on`

         * **User identifier column**: `loyalty_number`

         ![](/images/03-differential-privacy/10.png)

         ![](/images/03-differential-privacy/11.png)

      1. In the **Specify query controls** page, input the following details, then click **Next**:

         * **Control type**: `Allow any queries created by specific collaborators to run without review on this table`

         ![](/images/03-differential-privacy/12.png)

      1. After reviewing the details, click **Configure analysis rule**.

         This will bring us back to the configured table page. Click **Associate to collaboration**.

         ![](/images/03-differential-privacy/13.png)

         1. Pick `clean_rooms_lab_collab_03` then click **Choose collaboration**.

            ![](/images/03-differential-privacy/14.png)

         1. Input the following details:

            * **Configured table name**: `members`

            * **Table association Name**: `members`

            * **Service role name**: *(This should be prefilled. If not, give it a random name)*

            ![](/images/03-differential-privacy/15.png)
         
            ![](/images/03-differential-privacy/16.png)

         1. Click **Associate table**.
