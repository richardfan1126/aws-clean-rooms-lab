# Joining data from different data sources

In this session, we will use AWS Clean Rooms to join multiple tables from different accounts.

We will be creating 2 collaborations, using [**Aggregation**](https://docs.aws.amazon.com/clean-rooms/latest/userguide/analysis-rules-aggregation.html) and [**List**](https://docs.aws.amazon.com/clean-rooms/latest/userguide/analysis-rules-list.html) analysis rule respectively.

## Scenario

In most airlines, the loyalty program and the flights are operated by the same company.

But for the sake of this lab, let's imagine there is a loyalty program company (_Account 1_) and an airline company (_Account 2_).

For the loyalty program company, they want to know: Among all their member, who travel the most, so they can offer related products to them.

For the airline company, they want to know the demographic of their flyers (e.g., where they come from and how much they earn) so they can prepare more targeted promotions in the future.

By using AWS Clean Rooms, these two companies can safely share their data without exposing the whole dataset.

## Setup

You may use the automatic method to quickly deploy all resources.

But I recommend going through the manual method to understand the difference between the 2 analysis rules.

### Manual Deployment

See steps in [sub sessions](#sub-session)

### Automatic Deployment

1. Make sure you have set up your local environment correctly. [See instruction](/README.md#setup-your-environment)

1. Complete [**0. Prepare Glue database**](/00-prepare-glue-database) deployment

1. Run the following scripts to deploy resources

   ```bash
   cd 02-joining-tables/terraform/
   terraform init
   terraform apply -auto-approve
   ```

## Sub session

This session consists of 2 sub sessions:

* [**Aggregation analysis rule**](docs/aggregate.md)

* [**List analysis rule**](docs/list.md)
