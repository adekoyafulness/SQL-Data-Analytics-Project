/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.

SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.
===============================================================================
*/
-- Categories with the highest revenue
SELECT 
	category,
	total_amount,
	SUM (total_amount) OVER() AS overall_sales,
	CONCAT (ROUND ((CAST (total_amount AS FLOAT) / SUM (total_amount) OVER())* 100, 2), '%') AS percentage_total
FROM (
	SELECT
		p.category,
		SUM (s.sales_amount) AS total_amount
	FROM gold.fact_sales s
	LEFT JOIN gold.dim_products p
	ON p.product_key = s.product_key
	GROUP BY p.category
)t
ORDER BY total_amount DESC;


-- Country with the highest number of orders
WITH country_orders AS (
  SELECT
  	c.country,
  	SUM (quantity) AS total_orders
  FROM gold.fact_sales s
  LEFT JOIN gold.dim_customers c
  ON c.customer_key = s.customer_key
  GROUP BY c.country 
)

SELECT 
	country,
	total_orders,
	SUM (total_orders) OVER () AS total_order_quantity,
	CONCAT (ROUND (((CAST (total_orders AS FLOAT) / SUM (total_orders) OVER ()) * 100), 2), '%') AS orders_in_percentage
FROM country_orders
ORDER BY total_orders DESC
