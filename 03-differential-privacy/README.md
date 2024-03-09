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
