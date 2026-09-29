/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    - To give rank based on performance or other metrics.
    - To identify top N performance and bottom N performance.

SQL Functions Used:
    - Window Ranking Functions: RANK(), DENSE_RANK(), ROW_NUMBER(), TOP
    - Clauses: GROUP BY, ORDER BY
===============================================================================
*/

-- Which 5 products generate the highest revenue?
  ---- Simple ranking
SELECT TOP 5
  p.product_name,
  SUM (f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC;

  ----Using the window function RANK()
SELECT *
FROM (
	SELECT  
  	p.product_name,
  	SUM (f.sales_amount) AS total_revenue,
  	RANK() OVER (ORDER BY SUM (f.sales_amount) DESC) rank_products
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON f.product_key = p.product_key
	GROUP BY p.product_name
)t WHERE rank_products <= 5;

  ----Using the window function DENSE_RANK()
SELECT *
FROM (
	SELECT  
  	p.product_name,
  	SUM (f.sales_amount) AS total_revenue,
  	DENSE_RANK() OVER (ORDER BY SUM (f.sales_amount) DESC) rank_products
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON f.product_key = p.product_key
	GROUP BY p.product_name
)t WHERE rank_products <= 5;

  ----Using the window function ROW_NUMBER()
SELECT *
FROM (
	SELECT  
  	p.product_name,
  	SUM (f.sales_amount) AS total_revenue,
  	ROW_NUMBER() OVER (ORDER BY SUM (f.sales_amount) DESC) rank_products
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON f.product_key = p.product_key
	GROUP BY p.product_name
)t WHERE rank_products <= 5;


--What is the 5 worst performing product in term of Sales
  ---- Simple ranking
SELECT TOP 5
  p.product_name,
  SUM (f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_revenue ASC;

   ----Using the window function RANK()
SELECT *
FROM (
	SELECT  
  	p.product_name,
  	SUM (f.sales_amount) AS total_revenue,
  	RANK() OVER (ORDER BY SUM (f.sales_amount)) rank_products
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON f.product_key = p.product_key
	GROUP BY p.product_name
)t WHERE rank_products <= 5;


-- Find the top 10 customers who have generated the highest revenue
SELECT TOP 10
  c.customer_key,
  c.first_name,
  c.last_name,
  SUM (f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY 
		c.customer_key,
		c.first_name,
		c.last_name
ORDER BY total_revenue DESC;


-- Find the 3 customers with the fewer order placed
SELECT TOP 3
  c.customer_key,
  c.first_name,
  c.last_name,
  COUNT (DISTINCT order_number) AS total_order
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY 
		c.customer_key,
		c.first_name,
		c.last_name
ORDER BY total_order;
