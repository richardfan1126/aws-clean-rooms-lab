# Joining data from different data sources - List analysis rule

## Setup

### Manual Deployment

1. Login to the AWS Clean Rooms console using the `aws-clean-rooms-lab-account-1` credential.

   1. Click on **Create collaboration**
   
      ![](/images/02-joining-tables/list/01.png)

      1. Input the following details:

         * **Name**: `clean_rooms_lab_collab_02-list`

         * **Description**: `clean_rooms_lab_collab_02-list`

         * **Member 1 display name**: `member-data-source`

         * **Member 2 display name**: `flight-data-source`

         * **Member 2 AWS account ID**: *(The account ID of your second AWS account)*

         * **Member abilities**:

            * **Run queries**: `flight-data-source` (i.e. Account 2)

            * **Receive results**: `Same as who runs queries`

         * **Payment configuration**:

            * **Pay for queries**: `Same as who runs queries`

         * **Support query logging in this collaboration**: Checked

         ![](/images/02-joining-tables/list/02.png)

         ![](/images/02-joining-tables/list/03.png)

      1. Click **Next** to **Configure membership** page.

         Select **Yes, join by creating membership now** and **Turn on Query logging**, then click **Next**.

         ![](/images/02-joining-tables/list/04.png)

      1. Review the details, then click **Create collaboration and membership**.

         ![](/images/02-joining-tables/list/05.png)

   1. Click on **Configured tables** on the nav menu, then click **Configure new table**.

      ![](/images/02-joining-tables/list/06.png)

      1. Input the following details, then click **Configure new table**:

         * **Database**: `aws-clean-rooms-lab`

         * **Table**: `members`

         * **Which columns do you want to allow in collaborations?**: `All columns`

         * **Configured table Name**: `members_list`

         ![](/images/02-joining-tables/list/07.png)

         ![](/images/02-joining-tables/list/08.png)

      1. There is a warning saying **This table is not configure for querying**.

         Click **Configure analysis rule**.

         ![](/images/02-joining-tables/list/09.png)

      1. Choose `List` for **Analysis rule type** and `Guided flow` for **Creation method**, then click **Next**.

         ![](/images/02-joining-tables/list/10.png)

      1. Input the following details:

         * **Join controls**:

            * **Specify join columns**: `loyalty_number`

            * **Specify allowed operators for matching**: *(Uncheck all options)*
         
         * **Dimension controls**:

            * **Specify dimension columns**: *(Select all remaining columns)*

         ![](/images/02-joining-tables/list/11.png)

         ![](/images/02-joining-tables/list/12.png)

      1. After reviewing the details, click **Configure analysis rule**.

         This will bring us back to the configured table page. Click **Associate to collaboration**.

         ![](/images/02-joining-tables/list/13.png)

         1. Pick `clean_rooms_lab_collab_02-list` then click **Choose collaboration**.

            ![](/images/02-joining-tables/list/14.png)

         1. Input the following details:

            * **Configured table name**: `members_list`

            * **Table association Name**: `members`

            * **Service role name**: *(This should be prefilled. If not, give it a random name)*

            ![](/images/02-joining-tables/list/15.png)
            
            ![](/images/02-joining-tables/list/16.png)

         1. Click **Associate table**.

1. Login to the AWS Clean Rooms console using the `aws-clean-rooms-lab-account-2` credential.

   1. In the **Collaborations** page, you will find a collaboration available to join. Click on it.

      ![](/images/02-joining-tables/list/17.png)

      1. This is the collaboration we've just created in account 1.

         Review it, then click **Create membership**.

         ![](/images/02-joining-tables/list/18.png)

         1. Input the following details:

            * **Query logging**: `Turn on`

            * **Query results settings defaults**:

                * **Set default settings now**: *(Checked)*

                * **Results destination in Amazon S3**: `s3://<name_of_result_bucket_created_in_session_00>`

                * **Result format**: `CSV`

            ![](/images/02-joining-tables/list/19.png)

            ![](/images/02-joining-tables/list/20.png)

        1. Check the box to agree paying for the query compute costs, then click **Create membership**.

        1. Verify the details, then click **Create membership**.

         ![](/images/02-joining-tables/list/21.png)

   1. Click on **Configured tables** on the nav menu, then click **Configure new table**.

      ![](/images/02-joining-tables/list/06.png)

      1. Input the following details, then click **Configure new table**:

         * **Database**: `aws-clean-rooms-lab`

         * **Table**: `flight_history`

         * **Which columns do you want to allow in collaborations?**: `All columns`

         * **Configured table Name**: `flight_history_list`

         ![](/images/02-joining-tables/list/22.png)

         ![](/images/02-joining-tables/list/23.png)

      1. There is a warning saying **This table is not configure for querying**.

         Click **Configure analysis rule**.

         ![](/images/02-joining-tables/list/24.png)

      1. Choose `List` for **Analysis rule type** and `Guided flow` for **Creation method**, then click **Next**.

         ![](/images/02-joining-tables/list/10.png)

      1. Input the following details:

         * **Join controls**:

            * **Allow table to be queried by itself**: `No, only overlap can be queried`

            * **Specify join columns**: `loyalty_number`

            * **Specify allowed operators for matching**: *(Uncheck all options)*
         
         * **Dimension controls**:

            * **Specify dimension columns**: *(Select all remaining columns)*

         ![](/images/02-joining-tables/list/11.png)

         ![](/images/02-joining-tables/list/25.png)

      1. After reviewing the details, click **Configure analysis rule**.

         This will bring us back to the configured table page. Click **Associate to collaboration**.

         ![](/images/02-joining-tables/list/26.png)

         1. Pick `clean_rooms_lab_collab_02-list` then click **Choose collaboration**.

            ![](/images/02-joining-tables/list/14.png)

         1. Input the following details:

            * **Configured table name**: `flight_history_list`

            * **Table association Name**: `flight_history`

            * **Service role name**: *(This should be prefilled. If not, give it a random name)*

            ![](/images/02-joining-tables/list/27.png)
            
            ![](/images/02-joining-tables/list/16.png)

         1. Click **Associate table**.

## Exercise

1. Login to the AWS Clean Rooms console using the `aws-clean-rooms-lab-account-2` credential.

1. Goto **clean_rooms_lab_collab_02-list** -> **Queries** and and scroll down to the query editor.

   You will see 2 tables, one from the same AWS account and the other from the `flight-data-store` account.

   ![](/images/02-joining-tables/list/28.png)

1. We want to get a list of the members. Try running the following SQL:

   ```sql
   SELECT DISTINCT "members"."city",
         "members"."clv",
         "members"."country",
         "members"."education",
         "members"."enrollment_month",
         "members"."enrollment_type",
         "members"."enrollment_year",
         "members"."gender",
         "members"."loyalty_card",
         "members"."marital_status",
         "members"."postal_code",
         "members"."province",
         "members"."salary"
   FROM  "members"
   ```

   It will return an error `Inner join to query runner table required for table members`

   ![](/images/02-joining-tables/list/29.png)

   ![](/images/02-joining-tables/list/30.png)

   <details>

   <summary>Why an inner join is required?</summary>

   When using [List analysis rule](https://docs.aws.amazon.com/clean-rooms/latest/userguide/analysis-rules-list.html), at least one join with a configured table from the querying member is required.

   The list analysis rule allows collaboration members to view the details of the records. If the inner join is not required, it is actually sharing the table with the collaborators.

   So keep in mind, when using the List analysis rule, an inner join is required by default.

   </details>

1. Now, we want to know the demographic information of members who have redeemed more than 850 points in a month.

   Let's run the following query:

   ```sql
   SELECT DISTINCT
      "members"."loyalty_card",
      "members"."enrollment_type",
      "members"."enrollment_year",
      "members"."enrollment_month",
      "members"."gender",
      "members"."country",
      "members"."province",
      "members"."city",
      "flight_history"."year",
      "flight_history"."month",
      "flight_history"."points_redeemed"

   FROM "flight_history"

   INNER JOIN "members"
      ON "flight_history"."loyalty_number" = "members"."loyalty_number"

   WHERE
      "flight_history"."points_redeemed" > 850
   ```

   ![](/images/02-joining-tables/list/31.png)

   ![](/images/02-joining-tables/list/32.png)

### Questions

1. We are exposing too many details from the members table. How can we limit the airlines to see the members' living city?

   <details>

   <summary>Answer</summary>

   To limit what the collaborator can see from the table, we can modify the **List Columns** under **List controls**.

   Login to the member data source account (i.e., account 1), and modify the `members_list` configured table.

   Under the `listColumns` field, remove all the columns except `city` so the collaborators can see the members' living city.

   ![](/images/02-joining-tables/list/33.png)

   Now, go back to account2 and run the previous query, you will find that the columns except `city` are not allowed in the select clause.

   ![](/images/02-joining-tables/list/34.png)

   </details>

1. Can I set a rule to allow specific columns to be used as filters but not reveal them?

   <details>

   <summary>Answer</summary>

   The short answer is **No**.

   In the List analysis rule, **List Columns** is the only control on what columns can be used in **SELECT** and **WHERE** clauses. So, it is impossible to allow a column to be used as a filter but not reveal its content.

   Take one step back. Unlike aggregation analysis rule, list analysis rule allows collaborator to view the content of each record. So, in theory, if a column is allowed to be used as a filter, it is equivalent to revealing its content.

   Think about the following example:

   ```sql
   SELECT DISTINCT
      "members"."loyalty_card",
      "members"."enrollment_type",
      "members"."enrollment_year",
      "members"."enrollment_month",
      "members"."gender",
      "members"."country",
      "members"."province",
      "members"."city",
      "flight_history"."year",
      "flight_history"."month",
      "flight_history"."points_redeemed"

   FROM "flight_history"

   INNER JOIN "members"
      ON "flight_history"."loyalty_number" = "members"."loyalty_number"

   WHERE
      "flight_history"."points_redeemed" = 850
   ```

   If I run the above query, I can get a list of members.
   
   Even though I'm not selecting the `points_redeemed` column, but since I'm using a filter extracting members who have `"points_redeemed" = 850`.
   
   So, actually, I learned that those members have exactly 850 points redeemed in a month.

   </details>
