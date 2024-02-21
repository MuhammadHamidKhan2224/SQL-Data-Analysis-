USE walmart;
SELECT *FROM sales;
-----------------------------------------------------------------------------------------------------------------
------------------------------------------------Feature Engineering------------------------------------------------
------------------------------------------------------------------------------------------------------------------
-- Createing time of the day using case statement
SELECT 
    Time,
    CASE 
        WHEN Time < '12:00:00' THEN 'Morning'
        WHEN Time >= '12:00:00' AND Time < '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END AS Part_Of_Day
FROM sales
order by Time desc;


--- Adding new column into dataset having time of the days just created above
alter table sales add  time_of_day VARCHAR(20);
update sales
set time_of_day = (CASE 
                        WHEN CONVERT(time, Time) < '12:00' THEN 'Morning'
                        WHEN CONVERT(time, Time) >= '12:00' AND CONVERT(time, Time) < '16:00' THEN 'Afternoon'
                        ELSE 'Evening'
						END);
--- Create a new column named as day_name from date column that is given in dataset.
SELECT
    Date,
    DATENAME(WEEKDAY, date) AS dat_name
FROM
    sales;

ALTER TABLE sales
ADD day_name VARCHAR(10);

UPDATE sales
SET day_name = DATENAME(WEEKDAY, date);

-- Removing column name DayTime from dataset because it was an extra column.
ALTER TABLE sales
DROP COLUMN DayName;

-- Create a new column named as month_name from date column that is given in dataset.

SELECT
    Date,
    DATENAME(MONTH, date) AS month_name
	FROM
    sales;

ALTER TABLE sales
ADD month_name VARCHAR(10);

UPDATE sales
SET month_name = DATENAME(MONTH, date);
-----------------------------------------------------------------------------------------------------
-----------------------------------------Generic Question--------------------------------------------
-----------------------------------------------------------------------------------------
-- Q1: How many unique cities does the data have?
select count(distinct City) as Total_City from sales;

-- Q2: In which city is each branch?
Select City, Branch from sales
group by branch, City;

-- Q3: How many unique product lines does the data have?
select count(distinct Product_line) as Product_count from sales;

---Q4: What is the most common payment method?
select count(distinct Payment) from sales;

-- Q5: What month had the largest COGS?
SELECT TOP 1 
    FORMAT(Date, 'yyyy-MM') AS SaleMonth,
    SUM(COGS) AS TotalCOGS
FROM sales GROUP BY FORMAT(Date, 'yyyy-MM')
ORDER BY SUM(COGS) DESC;


-- Q6: What product line had the largest revenue?
select top 1 Total, Product_line as top_rated
from sales
order by Total desc;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                Product_line, 

-- Q7: What is the city with the largest revenue?
select top 1 Total, City as top_rated
from sales
order by Total desc;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                Product_line, 
                     
-- Q8:Which branch sold more products than average product sold?
select avg(Quantity) from sales
group by Branch;






-- Q9: What is the most common product line by gender?
select top 1 (Quantity),gender,  Product_line as mostly_used
from sales 
group by Gender
order by Quantity desc;
                     
-- Q10: What is the average rating of each product line?

--------------------------------------------------------------------------------------
-----------------------------------------Sales-----------------------------------------------
--------------------------------------------------------------------------------------
-- Q1: Number of sales made in each time of the day per weekday?
select time_of_day, Quantity as count_sales from sales 
group by day_name;


-- Q2: Which of the customer types brings the most revenue?
select top 1 Total, Customer_type from sales
order by Total desc

-- Q3: Which city has the largest tax percent/ VAT (Value Added Tax)?
select top 1 Tax_5,city from sales
order by Tax_5 desc;
-- Q4: Which customer type pays the most in VAT?
select top 1 Tax_5,Customer_type from sales
order by Tax_5 desc;

----------------------------------------------------------------------------------------
----------------------------------------Customer----------------------------------------
----------------------------------------------------------------------------------------
-- Q1: How many unique customer types does the data have?
select count(distinct customer_type) as unique_cus_type from sales;
select distinct customer_type from sales;

-- Q3: What is the most common customer type?
select customer_type,
count(*) as count 
from sales
group by Customer_type
order  by count desc;

-- Q4: Which customer type buys the most?
select customer_type,
count(*) as qty_count
from sales
group by Customer_type
order by qty_count desc;

-- Q5: What is the gender of most of the customers?
select Gender,
count(*) as gndr_count
from sales
group by Gender
order by gndr_count desc;
-- Q6: What is the gender distribution per branch?
select branch, gender,
count(*) as gndr_ditr
from sales
group by Branch
order by gndr_ditr;

-- Q7: Which time of the day do customers give most ratings?
select count(rating) as high_rate, time_of_day from sales
group by time_of_day
order by high_rate desc; 
-- Q7: Which time of the day do customers give most ratings per branch?
select count(rating) as high_rate, Branch, time_of_day from sales
group by time_of_day, Branch
order by high_rate desc; 
-- Q8: Which day fo the week has the best avg ratings?
select avg(rating) as bst_svg_rating, day_name from sales
group by day_name
order by bst_svg_rating desc; 
-- Q9: Which day of the week has the best average ratings per branch?
select avg(rating) as bst_svg_rating,Branch, day_name from sales
group by day_name, Branch
order by bst_svg_rating desc; 