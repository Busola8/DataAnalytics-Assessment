# DataAnalytics-Assessment

# SQL Case Studies – Adashi Staging

This project showcases SQL solutions to key business questions using data from Adashi's staging environment. Each query answers a specific analytical need, with clear logic, safeguards for common data issues, and a practical business focus.

---

## 1. High-Value Customers with Multiple Products

### Approach

This query helps identify customers who have both a savings plan and an investment plan. I used a base CTE to limit the scan of the `plans_plan` table, then aggregated the number of each plan type per customer. I also calculated total deposits from the `savings_savingsaccount` table (converted from kobo to naira) and joined the user table to display full customer names.

The final result filters for customers with at least one of each plan type and sorts them by total deposits, spotlighting customers with high financial activity and potential for cross-selling.

### Challenges

- Handled NULL values in names using `COALESCE`, so name concatenation doesn't fail.
- Ensured that plan types are correctly counted without scanning the `plans_plan` table more than once.
- Used proper joins to avoid losing customers without deposits but with valid plans.

---

## 2. Transaction Frequency Analysis

### Approach

To segment users by how often they transact, I calculated the number of transactions each customer makes per month, averaged it over time, and categorized them as High, Medium, or Low frequency users. I extracted the month using `DATE_FORMAT` and used a `CASE` expression to label the frequency.

This helps business teams understand customer engagement at a glance and tailor strategies to different user segments.

### Challenges

- Handled variability in customer activity over time by using monthly buckets.
- Took care to average per customer even if some months had zero transactions.
- Ordered output meaningfully using `FIELD()` to enforce logical category order.

---

## 3. Account Inactivity Alert

### Approach

This query flags savings or investment accounts that have had no transactions for over a year. I used a `LEFT JOIN` between `plans_plan` and `savings_savingsaccount` to catch both active and inactive accounts. By checking the most recent transaction date and comparing it to today's date, I determined how long each account has been dormant.

Accounts with no transactions at all are explicitly included using a `NULL` check on `last_transaction_date`.

### Challenges

- Correctly identified accounts with zero transaction history by allowing NULLs in the join.
- Used `DATEDIFF` and `DATE_SUB` to precisely define the 365-day cutoff.
- Labeled account types clearly using `CASE` to improve readability and filtering.

---

## 4. Customer Lifetime Value (CLV) Estimation

### Approach

To estimate the CLV of each customer, I calculated how long they've had an account (in months), how many transactions they've made, and the total transaction value. I then applied a simplified CLV formula that multiplies average monthly transactions by 12 and by a 0.1% profit margin on total transaction volume.

This gives a sense of customer profitability over a typical year, helping marketing or product teams prioritize retention or rewards.

### Challenges

- Avoided division by zero for new users by using `NULLIF` in the tenure calculation.
- Aggregated transaction value and count per customer while handling possible NULL join values.
- Converted transaction value from kobo to naira to keep the monetary value interpretable.

---
