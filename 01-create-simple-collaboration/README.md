# Simple Collaboration

In this session, we will create our first AWS Clean Rooms collaboration.

We will also create a simple configured table over the `members` table, restricting the data user to using aggregation queries only.

## Setup

In this part, we will walk through the AWS Clean Rooms console to create the collaboration and configured table.

If you want to skip it, please follow [automatic deployment](#automatic-deployment)

### Manual Deployment

### Automatic Deployment

1. Make sure you have set up your local environment correctly. [See instruction](/README.md#setup-your-environment)

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

      ![](/images/01-create-simple-collaboration/01.png)

   1. Click on **Queries** tab.

      The **Result destination** is set to the result bucket we created in session 0, and the result format is set to **CSV**.

      This means every time we run a query in this collaboration, the result will be saved into the S3 bucket in CSV format.

      ![](/images/01-create-simple-collaboration/02.png)

   1. Scroll down to the query editor.

      Here, you can see the tables available to this account and which columns can be used.

      ![](/images/01-create-simple-collaboration/03.png)

      1. In the query editor, run the following query to get the **gender** and **salary** on all individual records.

         ```sql
         SELECT gender, salary
         FROM members
         ```

         You will get an error message because the analysis rule only allows these 2 columns as the dimension columns, so we cannot directly query them.

         ![](/images/01-create-simple-collaboration/04.png)

      1. Turn on **Analysis builder UI** and try to build a query to get member count on each combination of **city**, **education**, **enrollment type**, **gender**, **loyalty card**, and **marital status**.

         ![](/images/01-create-simple-collaboration/05.png)

         After running the query, you will get the result. Note down how many results we can get from this query.

         ![](/images/01-create-simple-collaboration/06.png)

1. Login to the AWS Clean Rooms console using the `aws-clean-rooms-lab-account-1` credential.

   1. Click on **clean_rooms_lab_collab_01**.

      This time, you may notice there is no **Query** tab. It's because the membership of this account doesn't have the **Run queries** or **Receive results** capabilities.

      ![](/images/01-create-simple-collaboration/07.png)

   1. Go to the Amazon Athena console and try to run the same query we've run in the previous account.

      ```sql
      SELECT
      	COUNT(DISTINCT "members"."loyalty number") as member_count,
      	"members"."city",
      	"members"."education",
      	"members"."enrollment type",
      	"members"."gender",
      	"members"."loyalty card",
      	"members"."marital status"
      FROM "members"
      GROUP BY
      	"members"."city",
      	"members"."education",
      	"members"."enrollment type",
      	"members"."gender",
      	"members"."loyalty card",
      	"members"."marital status"
      ORDER BY member_count DESC;
      ```

      ![](/images/01-create-simple-collaboration/08.png)

      You will notice more than 2000 records compared to just a few we got previously.

      This is because the analysis rule in our configured table states that only results with more than 100 distinct **loyalty number** can be returned.

      So, the records less than 100 here were not shown in our previous query in AWS Clean Rooms.

1. Go back to `aws-clean-rooms-lab-account-2` and try more different queries in AWS Clean Rooms.
