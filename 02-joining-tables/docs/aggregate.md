# Joining data from different data sources - Aggregation analysis rule

## Setup

### Manual Deployment

1. Login to the AWS Clean Rooms console using the `aws-clean-rooms-lab-account-1` credential.

   1. Click on **Create collaboration**
   
      ![](/images/02-joining-tables/aggregate/01.png)

      1. Input the following details:

         * **Name**: `clean_rooms_lab_collab_02-aggregate`

         * **Description**: `clean_rooms_lab_collab_02-aggregate`

         * **Member 1 display name**: `member-data-source`

         * **Member 2 display name**: `flight-data-source`

         * **Member 2 AWS account ID**: *(The account ID of your second AWS account)*

         * **Member abilities**:

            * **Run queries**: `member-data-source` (i.e. Account 1)

            * **Receive results**: `Same as who runs queries`

         * **Payment configuration**:

            * **Pay for queries**: `Same as who runs queries`

         * **Support query logging in this collaboration**: Checked

         ![](/images/02-joining-tables/aggregate/02.png)

         ![](/images/02-joining-tables/aggregate/03.png)

      1. Click **Next** to **Configure membership** page.

         * Select **Yes, join by creating membership now**
         
         * **Turn on** Query logging
         
         * **Query results settings defaults**:

            * **Set default settings now**: *(Checked)*

            * **Results destination in Amazon S3**: `s3://<name_of_result_bucket_created_in_session_00>`

            * **Result format**: `CSV`

         * Check the box to agree paying for the query compute costs, then click **Next**.

         ![](/images/02-joining-tables/aggregate/04.png)
         
         ![](/images/02-joining-tables/aggregate/05.png)

   1. Click on **Configured tables** on the nav menu, then click **Configure new table**.

      ![](/images/02-joining-tables/aggregate/06.png)

      1. Input the following details, then click **Configure new table**:

         * **Database**: `aws-clean-rooms-lab`

         * **Table**: `members`

         * **Which columns do you want to allow in collaborations?**: `All columns`

         * **Configured table Name**: `members_aggregation`

         ![](/images/02-joining-tables/aggregate/07.png)

         ![](/images/02-joining-tables/aggregate/08.png)

      1. There is a warning saying **This table is not configure for querying**.

         Click **Configure analysis rule**.

         ![](/images/02-joining-tables/aggregate/09.png)

      1. Choose `Aggregation` for **Analysis rule type** and `Guided flow` for **Creation method**, then click **Next**.

         ![](/images/02-joining-tables/aggregate/10.png)

      1. Input the following details:

         * **Aggregate function**: `AVG`

         * **Columns**: `salary`, `clv`

         * **Join controls**:

            * **Allow table to be queried by itself**: `No, only overlap can be queried`

            * **Specify join columns**: `loyalty_number`

            * **Specify allowed operators for matching**: *(Uncheck all options)*
         
         * **Dimension controls**:

            * **Specify dimension columns**: *(Select all remaining columns)*

         * **Scalar functions**: `None`

         * **Aggregation constraints**:

            * **Column name**: `loyalty_number`

            * **Minimum number of distinct values**: `10`

         ![](/images/02-joining-tables/aggregate/11.png)

         ![](/images/02-joining-tables/aggregate/12.png)

         ![](/images/02-joining-tables/aggregate/13.png)
         
         ![](/images/02-joining-tables/aggregate/14.png)
         
         ![](/images/02-joining-tables/aggregate/15.png)

      1. After reviewing the details, click **Configure analysis rule**.

         This will bring us back to the configured table page. Click **Associate to collaboration**.

         ![](/images/02-joining-tables/aggregate/16.png)

         1. Pick `clean_rooms_lab_collab_02-aggregate` then click **Choose collaboration**.

            ![](/images/02-joining-tables/aggregate/17.png)

         1. Input the following details:

            * **Configured table name**: `members_aggregation`

            * **Table association Name**: `members`

            * **Service role name**: *(This should be prefilled. If not, give it a random name)*

            ![](/images/02-joining-tables/aggregate/18.png)
            
            ![](/images/02-joining-tables/aggregate/19.png)

         1. Click **Associate table**.

1. Login to the AWS Clean Rooms console using the `aws-clean-rooms-lab-account-2` credential.

   1. In the **Collaborations** page, you will find a collaboration available to join. Click on it.

      ![](/images/02-joining-tables/aggregate/20.png)

      1. This is the collaboration we've just created in account 1.

         Review it, then click **Create membership**.

         ![](/images/02-joining-tables/aggregate/21.png)

      1. Input the following details:

         * **Query logging**: `Turn on`

         ![](/images/02-joining-tables/aggregate/22.png)

      1. Verify the detail, then click **Create membership**.

         ![](/images/02-joining-tables/aggregate/23.png)

   1. Click on **Configured tables** on the nav menu, then click **Configure new table**.

      ![](/images/02-joining-tables/aggregate/06.png)

      1. Input the following details, then click **Configure new table**:

         * **Database**: `aws-clean-rooms-lab`

         * **Table**: `flight_history`

         * **Which columns do you want to allow in collaborations?**: `All columns`

         * **Configured table Name**: `flight_history_aggregation`

         ![](/images/02-joining-tables/aggregate/24.png)

         ![](/images/02-joining-tables/aggregate/25.png)

      1. There is a warning saying **This table is not configure for querying**.

         Click **Configure analysis rule**.

         ![](/images/02-joining-tables/aggregate/26.png)

      1. Choose `Aggregation` for **Analysis rule type** and `Guided flow` for **Creation method**, then click **Next**.

         ![](/images/02-joining-tables/aggregate/10.png)

      1. Input the following details:

         * **Aggregate function**: `AVG`

           **Columns**: `points_accumulated`, `points_redeemed`

         * **Aggregate function**: `SUM`

           **Columns**: `points_accumulated`, `points_redeemed`

         * **Aggregate function**: `COUNT DISTINCT`

           **Columns**: `loyalty_number`

         * **Join controls**:

            * **Allow table to be queried by itself**: `No, only overlap can be queried`

            * **Specify join columns**: `loyalty_number`

            * **Specify allowed operators for matching**: *(Uncheck all options)*
         
         * **Dimension controls**:

            * **Specify dimension columns**: *(Select all remaining columns)*

         * **Scalar functions**: `None`

         * **Aggregation constraints**:

            * **Column name**: `loyalty_number`

            * **Minimum number of distinct values**: `10`

         ![](/images/02-joining-tables/aggregate/27.png)

         ![](/images/02-joining-tables/aggregate/12.png)

         ![](/images/02-joining-tables/aggregate/28.png)
         
         ![](/images/02-joining-tables/aggregate/14.png)
         
         ![](/images/02-joining-tables/aggregate/29.png)

      1. After reviewing the details, click **Configure analysis rule**.

         This will bring us back to the configured table page. Click **Associate to collaboration**.

         ![](/images/02-joining-tables/aggregate/30.png)

         1. Pick `clean_rooms_lab_collab_02-aggregate` then click **Choose collaboration**.

            ![](/images/02-joining-tables/aggregate/17.png)

         1. Input the following details:

            * **Configured table name**: `flight_history_aggregation`

            * **Table association Name**: `flight_history`

            * **Service role name**: *(This should be prefilled. If not, give it a random name)*

            ![](/images/02-joining-tables/aggregate/31.png)
            
            ![](/images/02-joining-tables/aggregate/19.png)

         1. Click **Associate table**.

## Exercise

1. Login to the AWS Clean Rooms console using the `aws-clean-rooms-lab-account-1` credential.

1. Goto **clean_rooms_lab_collab_02-aggregate** -> **Queries** and and scroll down to the query editor.

   You will see 2 tables, one from the same AWS account and the other from the `flight-data-store` account.

   ![](/images/02-joining-tables/aggregate/32.png)

1. We want to know how many customers have flights booked each month. Try running the following SQL:

   ```sql
   SELECT COUNT(DISTINCT "flight_history"."loyalty_number"),
      "flight_history"."year",
      "flight_history"."month"
   FROM "flight_history"
   WHERE "flight_history"."flights_booked" > 0
   GROUP BY "flight_history"."year",
      "flight_history"."month"
   ORDER BY "flight_history"."year",
      "flight_history"."month"
   ```

   It will return an error `Inner join to query runner table required for table flight_history`

   ![](/images/02-joining-tables/aggregate/33.png)

   ![](/images/02-joining-tables/aggregate/34.png)

   This is because we have set the analysis rule to require only overlapped records to be queried.

   In this case, only queries with an `INNER JOIN` on a query runner's table are allowed.

1. Now, let's run a modified query with an `INNER JOIN` between `flight_history` and `members` _(which is owned by this account)_a

   ```sql
   SELECT COUNT(DISTINCT "flight_history"."loyalty_number"),
      "flight_history"."year",
      "flight_history"."month"
   FROM "flight_history"
      INNER JOIN "members" ON "flight_history"."loyalty_number" = "members"."loyalty_number"
   WHERE "flight_history"."flights_booked" > 0
   GROUP BY "flight_history"."year",
      "flight_history"."month"
   ORDER BY "flight_history"."year",
      "flight_history"."month"
   ```

   This time, we will get the result.

   ![](/images/02-joining-tables/aggregate/35.png)

   ![](/images/02-joining-tables/aggregate/36.png)

### Questions

* What is the difference between these 2 queries?

   <details>

   <summary>Answer</summary>

   The 1st query does not have `INNER JOIN`, so it includes all records from table `flight_history` where `flights_booked` is greater than 0.

   The 2nd query has an `INNER JOIN` statement between `flight_history` and `members` tables, so it only includes records with `loyalty_number` that exist in both tables.

   If we login to `aws-clean-rooms-lab-account-2` and run the 1st query on Amazon Athena, we will get a result with a larger member count.

   ![](/images/02-joining-tables/aggregate/37.png)

   We can use **Join controls** in AWS Clean Rooms to restrict data access to records that exist in both parties' databases only.

   </details>

* Members from which cities have the most average points redeemed on flight in Jan 2017?

   <details>

   <summary>Answer</summary>

   Using the following query:

   ```sql
   SELECT "members"."city",
      AVG("flight_history"."points_redeemed") AS avg_points_redeemed
   FROM "flight_history"
   INNER JOIN "members" ON "flight_history"."loyalty_number" = "members"."loyalty_number"
   WHERE "flight_history"."year" = '2017'
      AND "flight_history"."month" = '1'
   GROUP BY "members"."city"
   ORDER BY avg_points_redeemed DESC
   ```

   We can see members from **Moncton**, **Peace River** and **Tremblant** have the most average points redeemed on flight in Jan 2017.

   ![](/images/02-joining-tables/aggregate/38.png)

   </details>
