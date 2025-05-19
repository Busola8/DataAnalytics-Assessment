USE `adashi_staging`;

WITH monthly_transactions AS (
  -- Using CTE to for readability to calculate transaction for months
  SELECT
    owner_id,
    DATE_FORMAT(transaction_date, '%Y-%m') AS transaction_month,  -- Extraction of year and month from transaction date
    COUNT(*) AS transactions_per_month                             -- Counting transactions for each customer per month
  FROM savings_savingsaccount
  GROUP BY owner_id, transaction_month
),
avg_transactions_per_customer AS (
  -- Calculate average monthly transactions per customer over all months
  SELECT
    owner_id,
    AVG(transactions_per_month) AS avg_transactions_per_month     -- Average transactions per month per customer
  FROM monthly_transactions
  GROUP BY owner_id
),
frequency_level AS (
  -- Categorize customers based on their average monthly transaction frequency
  SELECT
    owner_id,
    avg_transactions_per_month,
    CASE 
      WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'     -- 10 or more transactions/month
      WHEN avg_transactions_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency' -- 3 to 9 transactions/month
      ELSE 'Low Frequency'                                             -- Less than 3 transactions/month
    END AS frequency_category
  FROM avg_transactions_per_customer
)

-- for each frequency category, count customers and average transactions
SELECT
  frequency_category,
  COUNT(*) AS customer_count,                                      -- Number of customers in each frequency category
  ROUND(AVG(avg_transactions_per_month), 2) AS avg_transactions_per_month  -- Average transactions
FROM frequency_level
GROUP BY frequency_category
ORDER BY FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency'); 