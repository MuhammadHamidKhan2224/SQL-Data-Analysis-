create database parch_and_posey;

use parch_and_posey;

select *from accounts;
select *from orders;
select *from region;
select *from sales_reps;
select *from web_events;
---------------------------------EXPLORATORY DATA ANALYSIS------------------------------------------------
--1-- Write a query that displays all the data in the occurred_at, account_id, and channel 
---columns of web_events table, and limits the output to only the first 10 rows.

SELECT occurred_at, account_id, channel
FROM web_events
ORDER BY occurred_at
OFFSET 0 ROWS
FETCH NEXT 10 ROWS ONLY;

--2-- Write a query to return the distinct channels in the web_events table.
SELECT DISTINCT channel
FROM web_events;

--3-- Write a query to return the 10 earliest orders in the orders table. Include the id, occurred_at, and
 -- total_amt_usd.

 SELECT TOP 10 id, occurred_at, total_amt_usd
FROM orders
ORDER BY occurred_at ASC;

--4--  Write a query to return the top 5 orders in terms of the largest total_amt_usd. Include the id,
 -- account_id, and total_amt_usd.

 SELECT TOP 5 id, account_id, total_amt_usd
FROM orders
ORDER BY total_amt_usd DESC;

--5-- Write a query to return the lowest 20 orders interms of smallest total_amt_usd. Include the id,
 -- account-id, and total_amt_usd.

SELECT TOP 20 id, account_id, total_amt_usd
FROM orders
ORDER BY total_amt_usd ASC;

--6--  Write a query that returns the first 5 rows and all columns from the orders
 -- table that have a dollar amount of gloss_amt_usd greater than or equal to 1000.

 SELECT TOP 5 *
FROM orders
WHERE gloss_amt_usd >= 1000;

--7--  Filter the accounts table to include the company name, website, and the primary point
 -- of contact (primary_poc) just for the EOG Resources Company in the accounts table.

 SELECT name, website, primary_poc
FROM accounts
WHERE name = 'EOG Resources';

--8--  Create a column that divides the gloss_amount_usd by the gloss_quantity to find the unit price
 --for the standard paper paper for each order. Limit the results to the first 10 orders, and include the id and the
 -- account_id field

 SELECT TOP 10 id, account_id, gloss_amt_usd / gloss_qty AS unit_price
FROM orders;

--9--  Write a query that returns all the companies whose name starts with 'C'.

Select * from accounts where name Like 'C%' ;

--10--  Use the accounts table to find the account name, primary_poc, and sales_rep_id for Walmart,
 -- Target, and Nordstrom

 SELECT
	name,
    primary_poc,
    sales_rep_id
FROM
	accounts
WHERE name IN ('Walmart', 'Target', 'Nordstrom');

--11--  Find the total amount of poster_qty paper ordered in the orders table.

SELECT SUM(poster_qty) AS total_poster_qty
FROM orders;

--12-- When was the earliest order ever placed? Only return the date

SELECT MIN(occurred_at) AS earliest_order_date
FROM orders;

--13-- When did the most recent(latest) web-event occur?

SELECT MAX(occurred_at) AS latest_web_event
FROM web_events;

--14-- Find the mean (average) amount spent per order on each paper type , as well as the mean
 --amount of each
 --paper type purchased per order. Your final answer should have 6 values- one for each paper
 --type for the
 --average number of sales, as well as average amount.

 SELECT AVG(standard_amt_usd) AS avg_standard_amt,
       AVG(gloss_amt_usd) AS avg_gloss_amt,
       AVG(poster_amt_usd) AS avg_poster_amt,
       AVG(standard_qty) AS avg_standard_qty,
       AVG(gloss_qty) AS avg_gloss_qty,
       AVG(poster_qty) AS avg_poster_qty
FROM orders;

--15--  Which accounts (by name) placed the earliest order? Your solution should have the account
 --name and the date of the order.

 SELECT top 1 a.name, MIN(o.occurred_at) AS earliest_order_date
FROM orders o
JOIN accounts a ON o.account_id = a.id
GROUP BY a.name
ORDER BY earliest_order_date ASC;

--16-- Try pulling standard_qty, gloss_qty, and poster_qty from the orders table, and the website and
 -- the primary_poc from the accounts table.

SELECT o.standard_qty, o.gloss_qty, o.poster_qty, a.website, a.primary_poc
FROM orders o
JOIN accounts a ON o.account_id = a.id;

--17-- Provide a table for all web_events associated with the account name of Walmart. There should
 --be three columns.
 --Be sure to include primary_oc, time_of_events, and the channel for each event. Additionally you
 --might choose to add a fourth column
 --to assure only Walmart events were chosen.

 SELECT a.primary_poc, we.occurred_at AS time_of_event, we.channel, a.name AS account_name
FROM web_events we
JOIN accounts a ON we.account_id = a.id
WHERE a.name = 'Walmart';

--18--  Write a query that uses UNION ALL on two instances (and selecting all columns) of the
 -- accounts table.

 SELECT *
FROM accounts
UNION ALL
SELECT *
FROM accounts;

--19-- Add a WHEREclause to each of the tables that you unioned in the query above, filtering the
 -- first table where name equals Walmart and filtering the second table where name equals Disney

 SELECT *
FROM accounts
WHERE name = 'Walmart'
UNION ALL
SELECT *
FROM accounts
WHERE name = 'Disney';

--20--  Perform the union in your first query (under the Appending Data via UNION header) in a
 --common table expression and name it double_accounts. Then do a COUNT the number of times a name
 -- appears in the double_accounts table. If you do this correctly, your query results should have a count of 2 for
 -- each name.

 WITH double_accounts AS (
  SELECT *
  FROM accounts
  UNION ALL
  SELECT *
  FROM accounts
)
SELECT name, COUNT(*) AS count
FROM double_accounts
GROUP BY name;




