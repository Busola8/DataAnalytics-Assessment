USE `adashi_staging`;

SELECT 
  u.id AS customer_id,  
  CONCAT(COALESCE(u.first_name, ''), ' ', COALESCE(u.last_name, '')) AS name,  
  -- account tenure in months since signup
  TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,
  -- total transactions from savings_savingsaccount table per customer
  COUNT(sa.id) AS total_transactions,
  -- Estimated Customer Lifetime Value (CLV)
  ROUND(
    (
      -- Average monthly transactions = total transactions / tenure in months
      COUNT(sa.id) / NULLIF(TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()), 0)) -- NULLIF to prevent dividing by zero
     * 12 * 0.001  -- Profit per transaction = 0.1% (0.001) of transaction value
    * SUM(sa.confirmed_amount) / 100, 2) -- Total transaction value (because it is in kobo)
  AS estimated_clv
FROM users_customuser u
LEFT JOIN savings_savingsaccount sa ON u.id = sa.owner_id  -- join the transactions to the customers
GROUP BY u.id, name, tenure_months  
ORDER BY estimated_clv DESC;  -- Sort results by highest CLV first




