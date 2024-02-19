use Bank_data;
select*from customer_nodes;
select *from regions; 
select *from customer_transactions
select *from transaction_data;
---------------------------------------------------------------------------------------------------------------------------
------------------------------------------------Customer Nodes Exploration-----------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
--Q1:How many unique nodes are there on the Data Bank system?
SELECT COUNT(DISTINCT node_id) AS unique_node_count
FROM customer_nodes;

-- Q2: What is the number of nodes per region?
select count(node_id) as num_of_nodes from customer_nodes
group by region_id
order by count(node_id) desc;

--Q3: How many customers are allocated to each region?
 select region_id, count(distinct customer_id) as Total_customer 
 from customer_nodes
 group by region_id
 order by count(distinct customer_id) desc;
 

--- Q4: How many days on average are customers reallocated to a different node?
-- without group by 
SELECT AVG(DATEDIFF(DAY, start_date, end_date)) AS avg_reallocation_days
FROM customer_nodes
WHERE
end_date IS NOT NULL AND YEAR(end_date) <> 9999
order by AVG(DATEDIFF(DAY, start_date, end_date));

-- with group by 
SELECT node_id, AVG(DATEDIFF(DAY, start_date, end_date)) AS avg_reallocation_days
FROM customer_nodes
WHERE
end_date IS NOT NULL AND YEAR(end_date) <> 9999
group by node_id
order by AVG(DATEDIFF(DAY, start_date, end_date));


-- Q5: What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
WITH ReallocationMetrics AS (
    SELECT
        region_id,
        DATEDIFF(DAY, start_date, end_date) AS ReallocationDays
    FROM customer_nodes
), PercentileCalculations AS (
    SELECT
        region_id,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ReallocationDays) OVER (PARTITION BY region_id) AS Median,
        PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY ReallocationDays) OVER (PARTITION BY region_id) AS P80,
        PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY ReallocationDays) OVER (PARTITION BY region_id) AS P95
    FROM ReallocationMetrics
)
SELECT
    region_id,
    AVG(Median) AS Median, 
    AVG(P80) AS P80,
    AVG(P95) AS P95
FROM PercentileCalculations
GROUP BY region_id;
-------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------Customer Transactions------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
select *from transaction_data;
-- Q1: What is the unique count and total amount for each transaction type?
Select txn_type,
Count(txn_type) as Total_count, Sum(txn_amount) as Total_txn_amount
From transaction_data
group by txn_type;

-- Q2: What is the average total historical deposit counts and amounts for all customers?
WITH deposit_sum AS (
    SELECT 
        customer_id,
        COUNT(*) AS txn_count, 
        SUM(txn_amount) AS total_deposit_amount
    FROM transaction_data
    WHERE txn_type = 'deposit'
    GROUP BY customer_id
)
SELECT 
    AVG(txn_count) AS avg_txn_count,
    AVG(total_deposit_amount) AS avg_total_deposit_amount
FROM deposit_sum;

-- Q3: For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
with count_summary as (
select customer_id, MONTH(txn_date) as month_num,
count(case when txn_type = 'deposit' then  1 end) as num_deposite,
count(case when txn_type = 'purchase' then  1 end) as num_purchase,
count(case when txn_type = 'withdrawal' then  1 end) as num_withdrawal
from transaction_data
group by customer_id, MONTH(txn_date))
select month_num, count(distinct customer_id) as num_of_customer
from count_summary
where num_deposite > 1 
and (num_purchase > 0 or num_withdrawal > 0)
group by month_num;

-- Q4: What is the closing balance for each customer at the end of the month?
WITH closing_balance AS (
    SELECT 
        customer_id, 
        MONTH(txn_date) AS month_num,
        SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE -txn_amount END) AS total_amount
    FROM transaction_data
    GROUP BY customer_id, MONTH(txn_date)
)
SELECT 
    customer_id,
    month_num,
    SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY month_num) AS running_total
FROM closing_balance;

-- Q5: What is the percentage of customers who increase their closing balance by more than 5%?

WITH CustomerBalances AS (
    SELECT
        customer_id,
        SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE 0 END) AS TotalDeposits,
        SUM(CASE WHEN txn_type = 'purchase' THEN txn_amount ELSE 0 END) AS TotalPurchases
    FROM
        transaction_data
    GROUP BY
        customer_id
),
BalanceChanges AS (
    SELECT
        customer_id,
        TotalDeposits,
        TotalPurchases,
        (TotalDeposits - TotalPurchases) AS NetBalanceChange,
        ((TotalDeposits - TotalPurchases) / NULLIF(TotalDeposits, 0)) * 100 AS PercentageIncrease
    FROM
        CustomerBalances
)

SELECT
    COUNT(*) AS TotalCustomers,
    SUM(CASE WHEN PercentageIncrease > 5 THEN 1 ELSE 0 END) AS CustomersIncreasedMoreThan5Percent,
    (SUM(CASE WHEN PercentageIncrease > 5 THEN 1 ELSE 0 END) * 1.0 / COUNT(*)) * 100 AS PercentageOfCustomersIncreasedMoreThan5Percent
FROM
    BalanceChanges;

------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------Data Allocation Challenge---------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

-- Step 1: Calculate the running customer balance up to the end of the previous month
WITH RunningBalance AS (
    SELECT 
        customer_id,
        txn_date,
        txn_amount,
        SUM(txn_amount) OVER (PARTITION BY customer_id ORDER BY txn_date) AS running_balance
    FROM 
        transaction_data
    WHERE 
        txn_date <= EOMONTH(GETDATE(), -1) 
)
SELECT 
    *
FROM 
    RunningBalance;
	
	-- Step 3: Calculate the minimum, average, and maximum values of the running balance for each customer
WITH RunningBalance AS (
    SELECT 
        customer_id,
        txn_date,
        txn_amount,
        SUM(txn_amount) OVER (PARTITION BY customer_id ORDER BY txn_date) AS running_balance
    FROM 
        transaction_data
    WHERE 
        txn_date < EOMONTH(GETDATE(), -1)  
),
CustomerBalance AS (
    SELECT 
        customer_id,
        YEAR(txn_date) AS year,
        MONTH(txn_date) AS month,
        MAX(running_balance) AS closing_balance,
        MIN(running_balance) AS min_running_balance,
        AVG(running_balance) AS avg_running_balance,
        MAX(running_balance) AS max_running_balance
    FROM 
        RunningBalance
    GROUP BY 
        customer_id,
        YEAR(txn_date),
        MONTH(txn_date)
)
SELECT 
    *
FROM 
    CustomerBalance;

-- Calculate the total data required on a monthly basis
SELECT 
    YEAR(txn_date) AS year,
    MONTH(txn_date) AS month,
    COUNT(*) AS total_data_required
FROM 
    transaction_data
GROUP BY 
    YEAR(txn_date),
    MONTH(txn_date)
ORDER BY 
    year, 
    month;


--------------Step 1
-- Calculate the running customer balance column
SELECT
    customer_id,
    txn_date,
    SUM(txn_amount) OVER (PARTITION BY customer_id ORDER BY txn_date) AS running_customer_balance
FROM
    transaction_data
ORDER BY
    customer_id,
    txn_date;
    
--------------Step 2
    -- Calculate the customer balance at the end of each month
SELECT
    customer_id,
    EOMONTH(txn_date) AS end_of_month, 
    SUM(txn_amount) AS customer_balance
FROM
    transaction_data
GROUP BY
    customer_id,
    EOMONTH(txn_date) 
ORDER BY
    customer_id,
    end_of_month;

--------------Step 3
-- Calculate minimum, average, and maximum values of the running balance for each customer
SELECT
    customer_id,
    MIN(running_customer_balance) AS min_balance,
    AVG(running_customer_balance) AS avg_balance,
    MAX(running_customer_balance) AS max_balance
FROM
    (
        SELECT
            customer_id,
            txn_date,
            SUM(txn_amount) OVER (PARTITION BY customer_id ORDER BY txn_date) AS running_customer_balance
        FROM
            transaction_data
    ) AS running_balances
GROUP BY
    customer_id;

-- Calculate the total data required on a monthly basis
	SELECT 
    YEAR(txn_date) AS [year],
    MONTH(txn_date) AS [month],
    COUNT(*) AS total_transactions
FROM 
    transaction_data
GROUP BY 
    YEAR(txn_date),
    MONTH(txn_date)
ORDER BY 
    [year], 
    [month];


--- Option 03: Option 3: data is updated real-time
	WITH RunningBalances AS (
    SELECT customer_id, txn_date,
           SUM(CASE txn_type
               WHEN 'deposit' THEN txn_amount
               WHEN 'withdrawal' THEN -txn_amount
               WHEN 'purchase' THEN -txn_amount
               ELSE 0 END) OVER (PARTITION BY customer_id ORDER BY txn_date) AS running_balance
    FROM transaction_data
)
SELECT customer_id,
       MIN(running_balance) AS min_balance,
       AVG(running_balance) AS avg_balance,
       MAX(running_balance) AS max_balance
FROM RunningBalances
GROUP BY customer_id;




WITH adjusted_amount AS (
    SELECT 
        customer_id, 
        MONTH(txn_date) AS month_number,
        DATENAME(month, txn_date) AS month,
        SUM(CASE 
            WHEN txn_type = 'deposit' THEN txn_amount
            ELSE -txn_amount
        END) AS monthly_amount
    FROM 
       transaction_data
    GROUP BY 
        customer_id, MONTH(txn_date), DATENAME(month, txn_date)
),
interest AS (
    SELECT 
        customer_id, 
        month_number,
        month, 
        monthly_amount,
        ROUND(((monthly_amount * 6.0 * 1) / (100.0 * 12)), 2) AS interest
    FROM 
        adjusted_amount
),
total_earnings AS (
    SELECT 
        customer_id, 
        month_number, 
        month,
        (monthly_amount + interest) as earnings
    FROM  
        interest
)
SELECT 
    month_number,
    month,
    SUM(CASE WHEN earnings < 0 THEN 0 ELSE earnings END) AS allocation
FROM 
    total_earnings
GROUP BY 
    month_number, month
ORDER BY 
    month_number, month;


