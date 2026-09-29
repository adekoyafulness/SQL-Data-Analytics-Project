/*
===============================================================================
Date Range Exploration 
===============================================================================
Purpose:
    - To understand the range of historical data.
    - To determine the boundaries of key data points.

SQL Functions Used:
    - MIN(), MAX(), DATEDIFF()
===============================================================================
*/
-- Find the date of the first and last order
SELECT 
MIN (order_date) first_order_date,
MAX (order_date) last_order_date 
FROM gold.fact_sales

-- Find the youngest and oldest customer
SELECT 
MIN (birthdate) oldest_birthdate,
DATEDIFF (year, MIN (birthdate), GETDATE()) oldest_age,
MAX (birthdate) youngest_birthdate,
DATEDIFF (year, MAX (birthdate), GETDATE()) youngest_age
FROM gold.dim_customers
