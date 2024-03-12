# Simple Collaboration

In this session, we will create our first AWS Clean Rooms collaboration.

We will also create a simple configured table over the `members` table, restricting the data user to using aggregation queries only.

* [Setup](#setup)
   + [Manual Deployment](#manual-deployment)
   + [Automatic Deployment](#automatic-deployment)
* [Exercise](#exercise)

## Setup

In this part, we will walk through the AWS Clean Rooms console to create the collaboration and configured table.

If you want to skip it, please follow [automatic deployment](#automatic-deployment)

### Manual Deployment

1. Complete [**0. Prepare Glue database**](/00-prepare-glue-database) deployment.

1. Login to the AWS Clean Rooms console using the `aws-clean-rooms-lab-account-1` credential.

   1. Click on **Create collaboration**
   
      ![](/images/01-create-simple-collaboration/01.png)

      1. Input the following details:

         * **Name**: `clean_rooms_lab_collab_01`

         * **Description**: `clean_rooms_lab_collab_01`

         * **Member 1 display name**: `member-data-source`

         * **Member 2 display name**: `flight-data-source`

         * **Member 2 AWS account ID**: *(The account ID of your second AWS account)*

         * **Member abilities**:

            * **Run queries**: `flight-data-store` (i.e. Account 2)

            * **Receive results**: `Same as who runs queries`

         * **Payment configuration**:

            * **Pay for queries**: `Same as who runs queries`

         * **Support query logging in this collaboration**: Checked

         ![](/images/01-create-simple-collaboration/02.png)

         ![](/images/01-create-simple-collaboration/03.png)

      1. Click **Next** to **Configure membership** page.

         Select **Yes, join by creating membership now** and **Turn on Query logging**, then click **Next**.

         ![](/images/01-create-simple-collaboration/04.png)

      1. Review the details, then click **Create collaboration and membership**.

         ![](/images/01-create-simple-collaboration/05.png)

   1. Click on **Configured tables** on the nav menu, then click **Configure new table**.

      ![](/images/01-create-simple-collaboration/06.png)

      1. Input the following details, then click **Configure new table**:

         * **Database**: `aws-clean-rooms-lab`

         * **Table**: `members`

         * **Which columns do you want to allow in collaborations?**: `All columns`

         * **Configured table Name**: `members_aggregation`

         ![](/images/01-create-simple-collaboration/07.png)

      1. There is a warning saying **This table is not configure for querying**.

         Click **Configure analysis rule**.

         ![](/images/01-create-simple-collaboration/08.png)

      1. Choose `Aggregation` for **Analysis rule type** and `Guided flow` for **Creation method**, then click **Next**.

         ![](/images/01-create-simple-collaboration/09.png)

      1. Input the following details:

         * **Aggregate function**: `COUNT_DISTINCT`

         * **Columns**: `loyalty_number`

         * **Join controls**:

            * **Allow table to be queried by itself**: `Yes`

            * **Specify join columns**: *(Leave it blank)*

            * **Specify allowed operators for matching**: *(Uncheck all options)*
         
         * **Dimension controls**:

            * **Specify dimension columns**: *(Select all remaining columns)*

         * **Scalar functions**: `None`

         * **Aggregation constraints**:

            * **Column name**: `loyalty_number`

            * **Minimum number of distinct values**: `100`

         ![](/images/01-create-simple-collaboration/10.png)

         ![](/images/01-create-simple-collaboration/11.png)

         ![](/images/01-create-simple-collaboration/12.png)

      1. After reviewing the details, click **Configure analysis rule**.

         This will bring us back to the configured table page. Click **Associate to collaboration**.

         ![](/images/01-create-simple-collaboration/13.png)

         1. Pick `clean_rooms_lab_collab_01` then click **Choose collaboration**.

            ![](/images/01-create-simple-collaboration/14.png)

         1. Input the following details:

            * **Configured table name**: `members_aggregation`

            * **Table association Name**: `members`

            * **Service role name**: *(This should be prefilled. If not, give it a random name)*

            ![](/images/01-create-simple-collaboration/15.png)

         1. Click **Associate table**.

1. Login to the AWS Clean Rooms console using the `aws-clean-rooms-lab-account-2` credential.

   In the **Collaborations** page, you will find a collaboration available to join. Click on it.

   ![](/images/01-create-simple-collaboration/16.png)

   1. This is the collaboration we've just created in account 1.

      Review it, then click **Create membership**.

      ![](/images/01-create-simple-collaboration/17.png)

   1. Input the following details:

      * **Query logging**: `Turn on`

      * **Query results settings defaults**:

         * **Set default settings now**: *(Checked)*

         * **Results destination in Amazon S3**: `s3://<name_of_result_bucket_created_in_session_00>`

         * **Result format**: `CSV`

      ![](/images/01-create-simple-collaboration/18.png)

   1. Check the box to agree paying for the query compute costs, then click **Create membership**.

      ![](/images/01-create-simple-collaboration/19.png)

### Automatic Deployment

1. Make sure you have set up your local environment correctly. [See instruction](/README.md#setup-your-environment)

1. Complete [**0. Prepare Glue database**](/00-prepare-glue-database) deployment

1. Run the following scripts to deploy resources

   ```bash
   cd 01-create-simple-collaboration/terraform/
   terraform init
   terraform apply -auto-approve
   ```

## Exercise

1. Login to the AWS Clean Rooms console using the `aws-clean-rooms-lab-account-2` credential.

   1. Click on **clean_rooms_lab_collab_01** and look for the **Members** tab.

      You will see 2 members in this collaboration and the capabilities of each member.

      Notice the currently logged-in account can **Run queries** and **Receive results**

      ![](/images/01-create-simple-collaboration/20.png)

   1. Click on **Queries** tab.

      The **Result destination** is set to the result bucket we created in session 0, and the result format is set to **CSV**.

      This means every time we run a query in this collaboration, the result will be saved into the S3 bucket in CSV format.

      ![](/images/01-create-simple-collaboration/21.png)

   1. Scroll down to the query editor.

      Here, you can see the tables available to this account and which columns can be used.

      ![](/images/01-create-simple-collaboration/22.png)

      1. In the query editor, run the following query to get the **gender** and **salary** on all individual records.

         ```sql
         SELECT gender, salary
         FROM members
         ```

         You will get an error message because the analysis rule only allows these 2 columns as the dimension columns, so we cannot directly query them.

         ![](/images/01-create-simple-collaboration/23.png)

      1. Turn on **Analysis builder UI** and try to build a query to get member count on each combination of **city**, **education**, **enrollment_type**, **gender**, **loyalty_card**, and **marital_status**.

         ![](/images/01-create-simple-collaboration/24.png)

         After running the query, you will get the result. Note down how many results we can get from this query.

         ![](/images/01-create-simple-collaboration/25.png)

1. Login to the AWS Clean Rooms console using the `aws-clean-rooms-lab-account-1` credential.

   1. Click on **clean_rooms_lab_collab_01**.

      This time, you may notice there is no **Query** tab. It's because the membership of this account doesn't have the **Run queries** or **Receive results** capabilities.

      ![](/images/01-create-simple-collaboration/26.png)

      1. Click on the table `members` and view the analysis rule we've set on this table.

         Note that we have set the **Aggregation threshold** on column `loyalty_number` to `100`.

         ![](/images/01-create-simple-collaboration/27.png)

      1. You can also view the analysis rule in JSON format.

         ![](/images/01-create-simple-collaboration/28.png)

   1. Go to the Amazon Athena console and try to run the same query we've run in the previous account.

      ```sql
      SELECT
      	COUNT(DISTINCT "members"."loyalty_number") as member_count,
      	"members"."city",
      	"members"."education",
      	"members"."enrollment_type",
      	"members"."gender",
      	"members"."loyalty_card",
      	"members"."marital_status"
      FROM "members"
      GROUP BY
      	"members"."city",
      	"members"."education",
      	"members"."enrollment_type",
      	"members"."gender",
      	"members"."loyalty_card",
      	"members"."marital_status"
      ORDER BY member_count DESC;
      ```

      ![](/images/01-create-simple-collaboration/29.png)

      You will notice more than 2000 records compared to just a few we got previously.

      This is because the analysis rule in our configured table states that only results with more than 100 distinct **loyalty_number** can be returned.

      So, the records less than 100 here were not shown in our previous query in AWS Clean Rooms.

1. Go back to `aws-clean-rooms-lab-account-2` and try more different queries in AWS Clean Rooms.
