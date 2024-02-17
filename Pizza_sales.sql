create database pizza;
use pizza; 

select *from pizza_sales;

-- A: KPI's
-- 01: Total Revenue
select sum(total_price) as Total_Revnue from pizza_sales;

-- 02: Average Order Value
select sum(total_price) / count(distinct order_id) as Avg_Order_Value
from pizza_sales;

-- 03: Total Pizzas Sold
SELECT SUM(quantity) AS Total_pizza_sold FROM pizza_sales

-- 04: Total Orders
SELECT COUNT(DISTINCT order_id) AS Total_Orders FROM pizza_sales

-- 05: Average Pizzas Per Order
SELECT CAST(CAST(SUM(quantity) AS DECIMAL(10,2)) / 
CAST(COUNT(DISTINCT order_id) AS DECIMAL(10,2)) AS DECIMAL(10,2))
AS Avg_Pizzas_per_order
FROM pizza_sales;

-- B. Daily Trend for Total Orders
select DATENAME(DW, order_date) as Order_Day , count(distinct order_id) as Total_Orders 
from pizza_sales
group by DATENAME(DW, order_date);

-- C. Hourly Trend for Orders
select DATEPART(Hour, order_time) as Order_Hours, count(distinct order_id) as Total_Orders 
from pizza_sales
group by DATEPART(Hour, order_time); 

-- D. % of Sales by Pizza Category
SELECT pizza_category, CAST(SUM(total_price) AS DECIMAL(10,2)) as total_revenue,
CAST(SUM(total_price) * 100 / (SELECT SUM(total_price) from pizza_sales) AS DECIMAL(10,2)) AS PCT
FROM pizza_sales
GROUP BY pizza_category

-- E. % of Sales by Pizza Size
SELECT pizza_size, CAST(SUM(total_price) AS DECIMAL(10,2)) as total_revenue,
CAST(SUM(total_price) * 100 / (SELECT SUM(total_price) from pizza_sales) AS DECIMAL(10,2)) AS PCT
FROM pizza_sales
GROUP BY pizza_size
ORDER BY pizza_size desc;

-- F. Total Pizzas Sold by Pizza Category
select pizza_category, sum(quantity) as Total_Pizza_Sold
from pizza_sales
group by pizza_category;

-- G. Top 5 Best Sellers by Total Pizzas Sold
select Top 5 pizza_name, sum(quantity) as Total_Pizza_Sold
from pizza_sales
group by pizza_name
order by sum(quantity) desc;

-- H. Bottom 5 Best Sellers by Total Pizzas Sold
select Top 5 pizza_name, sum(quantity) as Total_Pizza_Sold
from pizza_sales
group by pizza_name
order by sum(quantity) asc;



