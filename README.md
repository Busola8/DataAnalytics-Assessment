# DataAnalytics-Assessment

This project showcases SQL solutions to key business questions using data from the provided environment. Each query answers a specific analytical need, with clear logic and safeguards for common data issues.

---

## 1. High-Value Customers with Multiple Products

### Approach

This query helps identify customers who have both a savings plan and an investment plan. I used a base CTE to limit the scan of the `plans_plan` table, then aggregated the number of each plan type per customer. I also calculated total deposits from the `savings_savingsaccount` table (converted from kobo to naira) and joined the user table to display full customer names.

The final result filters for customers with at least one of each plan type and sorts them by total deposits, spotlighting customers with high financial activity and potential for cross-selling.

### Challenges

- I had to handled NULL values in names using `COALESCE`, so name concatenation (first and last name since the name column was filled with nulls) doesn't fail , I also made sure to improve table scan execution plan by ensuring that plan types are correctly counted without scanning the `plans_plan` table more than once.
- Then i also had o be careful during joins to avoid losing customers without deposits but with valid plans.

---

## 2. Transaction Frequency Analysis

### Approach

To segment users by how often they transact, I calculated the number of transactions each customer makes per month, averaged it over time, and categorized them as High, Medium, or Low frequency users. I extracted the month using `DATE_FORMAT` and used a `CASE` expression to label the frequency.

This way you can tell the high value customers at a glance and tailor strategies to different user segments.

### Challenges

- I made use of CTE here for readability and I ordered output meaningfully using `FIELD()` to enforce logical category order.

---

## 3. Account Inactivity Alert

### Approach

This query flags savings or investment accounts that have had no transactions for over a year. I used a `LEFT JOIN` between `plans_plan` and `savings_savingsaccount` to catch both active and inactive accounts. With the most recent transaction date and then comparing it to today's date, I could tell how long each account has been dormant.

Just as a precaution, accounts with no transactions at all are explicitly included using a `NULL` check on `last_transaction_date`.

### Challenges

- I made use of `DATEDIFF` and `DATE_SUB` to define the 365-day cutoff.
- I also abeled account types clearly using `CASE` to improve readability and filtering.

---

## 4. Customer Lifetime Value (CLV) Estimation

### Approach

To estimate the CLV of each customer, I calculated how long they've had an account (in months), how many transactions they've made, and the total transaction value. I then applied the CLV formula that multiplied average monthly transactions by 12 and by a 0.1% profit margin on total transaction volume.

So this one gave me customer profitability

### Challenges

- Since we are calculating,I avoided division by zero for new users by using `NULLIF` in the tenure calculation.Then i also had to handle null values during the calculation
- Then I converted transaction value from kobo to naira 

---
