# Differential Privacy

In this session, we will explore [AWS Clean Rooms Differential Privacy](https://docs.aws.amazon.com/clean-rooms/latest/userguide/differential-privacy.html) and experience how differential privacy can be applied to data collaboration.

* [What is Differential Privacy?](#what-is-differential-privacy)
* [Scenario](#scenario)
* [Setup](#setup)
   + [Manual Deployment](#manual-deployment)
   + [Automatic Deployment](#automatic-deployment)
* [Exercise](#exercise)

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

<a id="scenario-example"></a>

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

In this part, we will walk through the AWS Clean Rooms console to create the collaboration and configured table for Differential Privacy.

If you want to skip it, please follow [automatic deployment](#automatic-deployment)

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

   1. After configuring the table association, you will see a warning message: `Differential privacy policy required` beside the table name.

      ![](/images/03-differential-privacy/17.png)

      1. Click **Configure differential privacy policy**

      1. In the configuration page, there are 2 parameters you can configure:

         * **Privacy budget**

            A smaller privacy budget means fewer queries can be run, but it can minimize privacy loss.

         * **Noise added per query**

            More noise means the query results are less accurate but consume less privacy budget.

         ![](/images/03-differential-privacy/18.png)

      1. Click on the estimate of **Resulting utility per month**

         On the right-hand side, you can preview how different configurations affect the number of queries and the query results.

         E.g., When tuning up the Noise, we can run more queries, but the result accuracy will decrease.

         ![](/images/03-differential-privacy/19.png)

         ![](/images/03-differential-privacy/20.png)

      1. Use the following default settings, then click **Configure**

         * **Privacy budget**: `10`

         * **Refresh privacy budget monthly**: (Checked)

         * **Noise added per query**: `30`

      1. You will see that the differential privacy policy has been applied to the collaboration.

         Click on the warning message `No - accounts haven't been allowed`, then click `Edit analysis rule`

         ![](/images/03-differential-privacy/21.png)

      1. Add the account ID of the data consumer (i.e., account 2) into the Analysis rule definition, then click **Save changes**

         Replace `<account_id_of_data_consumer>` with the account ID.

         ```json
         {
            ...
            "allowedAnalysisProviders": [
               "<account_id_of_data_consumer>"
            ],
            ...
         }
         ```

         ![](/images/03-differential-privacy/22.png)

1. Login to the AWS Clean Rooms console using the `aws-clean-rooms-lab-account-2` credential.

   1. In the **Collaborations** page, you will find a collaboration available to join. Click on it.

      ![](/images/03-differential-privacy/23.png)

      1. This is the collaboration we've just created in account 1.

         Review it, then click **Create membership**.

         ![](/images/03-differential-privacy/24.png)

      1. Input the following details:

         * **Query logging**: `Turn on`

         * **Query results settings defaults**:

            * **Set default settings now**: *(Checked)*

            * **Results destination in Amazon S3**: `s3://<name_of_result_bucket_created_in_session_00>`

            * **Result format**: `CSV`

         ![](/images/03-differential-privacy/25.png)

         ![](/images/03-differential-privacy/26.png)

      1. Check the box to agree paying for the query compute costs, then click **Create membership**.

         ![](/images/03-differential-privacy/27.png)

      1. Verify the detail, then click **Create membership**.

         ![](/images/03-differential-privacy/28.png)

### Automatic Deployment

1. Make sure you have set up your local environment correctly. [See instruction](/README.md#setup-your-environment)

1. Complete [**0. Prepare Glue database**](/00-prepare-glue-database) deployment

1. Run the following scripts to deploy resources

   ```bash
   cd 03-differential-privacy/terraform/
   terraform init
   terraform apply -auto-approve
   ```

## Exercise

1. Login to the AWS Clean Rooms console using the `aws-clean-rooms-lab-account-2` credential.

1. Goto **clean_rooms_lab_collab_02** -> **Queries** and and scroll down to the query editor.

   Under the **Tables** session, you can see the privacy budget used in this collaboration and the estimated remaining aggregate functions.

   ![](/images/03-differential-privacy/29.png)

   1. Click **View impact**. You can see the details of the differential privacy parameters

      ![](/images/03-differential-privacy/30.png)

      You can also click on the estimation to see the breakdown for different aggregation functions.

      ![](/images/03-differential-privacy/31.png)

      <details>

      <summary>Question: Why the estimated remaining queries for each function are different?</summary>

      The amount of information a query exposes differs depending on the aggregation function used.

      The more information a query exposes, the more privacy budget will be consumed, and the amount of query that can be run is lower.

      The `COUNT DISTINCT` function only tells us the number of distinct values in the table, so it consumes the least privacy budget.

      The `SUM` function uses the value of a record (e.g., `salary` of the member) to perform the calculation, so it consumes more privacy budget than the `COUNT` AND `COUNT DISTINCT` function.

      The `AVG` function combines `SUM` and `COUNT` functions, so it consumes the most privacy budget.

      </details>

   1. Run the following query

      ```sql
      SELECT COUNT(DISTINCT "members"."loyalty_number")
      FROM "members"
      ```

      ![](/images/03-differential-privacy/32.png)

      After the query completes, look at the differential privacy summary under **Tables** session.

      You can see the amount of remaining aggregate functions has decreased.

      ![](/images/03-differential-privacy/33.png)

   1. Run the same query again.

      Comparing the results of 2 query runs, we will notice a slight difference.

      This is due to the noise added to the result.

      <details>

      <summary>Question: How can the added noise help protect privacy?</summary>

      Consider the [example](#scenario-example) in the Scenario section.

      ```sql
      SELECT COUNT(DISTINCT "loyalty_number")
      FROM "members";
      ```

      ```sql
      SELECT COUNT(DISTINCT "loyalty_number")
      FROM "members"
      WHERE "city" <> 'A Very Small Town';
      ```

      When differential privacy is applied, the first query's result may not be exactly `300`. Because of the added noise, it may be `295`, `301`, `310`, etc.

      Similarly, the result of the second query may not be exactly `280` too. It may be `290`, `270`, or even `300`.

      Data consumers cannot confidently say how many members are from the specified small town by looking at the result.

      Actually, they cannot even tell if any member from that town exists.

      Differential privacy protects individuals' privacy by adding a small amount of noise so data consumers cannot infer individuals' data from a small subset of the database.

      </details>

   1. Now, let's run the following query to get the average salary of all members

      ```sql
      SELECT AVG("members"."salary")
      FROM "members"
      ```

      ![](/images/03-differential-privacy/34.png)

      After the query completes, look at the differential privacy summary under **Tables** session.

      The decrease of remaining aggregate functions is larger than running `COUNT DISTINCT` queries. This is because the privacy budget consumed by `AVG` is more than `COUNT DISTINCT`.

      ![](/images/03-differential-privacy/35.png)

1. Now, let's log in to the AWS Clean Rooms console using the `aws-clean-rooms-lab-account-1` credential.

   We will set up a new differential privacy policy with a smaller privacy budget.

   1. In the AWS Clean Rooms console, click the collaboration `clean_rooms_lab_collab_03`

      Under **Table** tab, click **Delete** beside **Differential privacy policy**.

      Then click **Delete** in the popup box.

      ![](/images/03-differential-privacy/36.png)

      ![](/images/03-differential-privacy/37.png)

   1. Go back to the collaboration **Tables** tab, Click **Configure differential privacy policy**

      ![](/images/03-differential-privacy/38.png)

   1. This time, we will set the **Privacy budget** as `1`.

      After setting the Privacy budget, click **Configure**.

      ![](/images/03-differential-privacy/39.png)

   1. Now, let's login to AWS Clean Rooms console again using the `aws-clean-rooms-lab-account-2` credential.

      Go to the **Query** tab of the collaboration, you will see the aggregate functions remaining for the new differential privacy policy.

      ![](/images/03-differential-privacy/40.png)

   1. Let's run the following query again

      ```sql
      SELECT AVG("members"."salary")
      FROM "members"
      ```

      ![](/images/03-differential-privacy/34.png)

      After the query completes, look at the differential privacy summary under **Tables** session.

      You will see that the remaining aggregate functions have decreased to nearly 0.

      ![](/images/03-differential-privacy/41.png)

   1. Let's rerun the query.

      This time, the query will return an error message saying we don't have enough aggregations remaining to run this query.

      ![](/images/03-differential-privacy/42.png)

      This is because the first query has already used all the privacy budget the policy allows; further queries are not allowed.

      _(If the remaining aggregate functions is not 0 after the first query, try run the query again until it hit 0. With a small privacy budget allowed, it should quickly become 0.)_

1. Try running the query you have used in [Session 1](/01-create-simple-collaboration/) and see how the results differ with and without differential privacy.
