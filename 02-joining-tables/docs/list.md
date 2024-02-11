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

        1. Verify the detail, then click **Create membership**.

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
