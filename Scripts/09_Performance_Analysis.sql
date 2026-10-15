/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.

SQL Functions Used:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
===============================================================================
*/

-- Analyze the yearly performance of products by comparing their sales to both the average sales performance of the product and the previous year's sales

WITH yearly_product_sales AS (
	SELECT
	p.product_name,
	YEAR (s.order_date) AS order_year,
	SUM (s.sales_amount) AS current_sales
	FROM gold.fact_sales s
	LEFT JOIN gold.dim_products p
	ON s.product_key = p.product_key
	WHERE s.order_date IS NOT NULL
	GROUP BY 
          YEAR (s.order_date),
			    p.product_name
)

SELECT 
	order_year,
	product_name,
	current_sales,
	AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
	current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
	CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'above_avg'
		 WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'below_avg'
		 ELSE 'avg'
	END   AS avg_change,
	LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year ASC) AS py_sales,
	current_sales - LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year ASC) AS py_diff,
	CASE WHEN current_sales - LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year ASC) > 0 THEN 'increasing'
		 WHEN current_sales - LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year ASC) < 0 THEN 'decreasing'
		 ELSE 'no_change'
	END   AS py_change
FROM yearly_product_sales
ORDER BY  product_name,
		      order_year
