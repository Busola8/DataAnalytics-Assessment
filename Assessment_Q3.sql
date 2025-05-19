USE `adashi_staging`;

SELECT *
FROM (
  SELECT 
    p.id AS plan_id,  
    p.owner_id,       
    CASE 
      WHEN p.is_regular_savings = 1 THEN 'Savings'  -- Label as 'Savings' if it is a regular savings plan
      WHEN p.is_a_fund = 1 THEN 'Investment'        -- Label as 'Investment' if it is an investment
      ELSE 'Neither'                                  -- Otherwise, Neither 
    END AS type,
    MAX(s.transaction_date) AS last_transaction_date,  -- Most recent transaction date for this plan
    DATEDIFF(CURDATE(), MAX(s.transaction_date)) AS inactivity_days  -- Days since last transaction 
  FROM plans_plan p
  LEFT JOIN savings_savingsaccount s ON p.id = s.plan_id  -- Join transactions to plans by plan_id, allowing plans with no transactions
  WHERE p.is_regular_savings = 1 OR p.is_a_fund = 1         -- taking only savings or investment plans
  GROUP BY p.id, p.owner_id, type                            -- latest transaction per plan
) AS b
WHERE b.last_transaction_date IS NULL                        -- Include plans with no transactions ever
   OR b.last_transaction_date < DATE_SUB(CURDATE(), INTERVAL 1 YEAR)  -- Or plans inactive for over 1 year
ORDER BY b.inactivity_days DESC;                              -- Order by inactivity days i.e longest inactivity first