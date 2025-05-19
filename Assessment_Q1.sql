USE `adashi_staging`;

WITH CTE_base_plan AS (
  SELECT owner_id, is_regular_savings, is_a_fund
  FROM plans_plan
),

-- CTE to count how many savings and investment plans each customer has
CTE_counts AS (
  SELECT 
    owner_id,
    -- number of savings plans per customer
    SUM(CASE WHEN is_regular_savings = 1 THEN 1 ELSE 0 END) AS savings_count,
    -- number of investment plans per customer
    SUM(CASE WHEN is_a_fund = 1 THEN 1 ELSE 0 END) AS investment_count
  FROM CTE_base_plan
  GROUP BY owner_id
),

-- CTE to calculate total deposits per customer, rounded and converted
CTE_total_deposits AS (
  SELECT 
    owner_id, 
    ROUND(SUM(confirmed_amount) / 100, 2) AS total_deposits  -- Divide by 100 to convert 
  FROM savings_savingsaccount
  GROUP BY owner_id
),

-- CTE to concatenate customer first and last names into a full name
CTE_customername AS (
  SELECT 
    id,
    CONCAT(COALESCE(first_name, ''), ' ', COALESCE(last_name, '')) AS name  -- COALESCE to handle NULL names
  FROM users_customuser
)

-- to return customers with both a funded savings and investment plan
SELECT 
  c.owner_id,               
  cn.name,                  -- Customer full name
  c.savings_count,          -- Number of savings plans they have
  c.investment_count,       -- Number of investment plans they have
  ctd.total_deposits        
FROM CTE_counts c
LEFT JOIN CTE_customername cn ON c.owner_id = cn.id           
LEFT JOIN CTE_total_deposits ctd ON c.owner_id = ctd.owner_id -- Table joins
WHERE c.savings_count >= 1 AND c.investment_count >= 1        -- customers with both plan types
ORDER BY ctd.total_deposits DESC;                             -- Sort by total deposits (highest first)