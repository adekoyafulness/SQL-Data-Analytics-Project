/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - sales history (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/
-- =============================================================================
-- Create Report: gold.report_products
-- =============================================================================
IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO
  
CREATE VIEW gold.report_products AS

WITH base_query AS (
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from fact_sales and dim_products
---------------------------------------------------------------------------*/
    SELECT 
        s.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        s.customer_key,
        p.cost,
        s.sales_amount,
        s.order_date,
        s.order_number,
        s.quantity
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
    ON s.product_key = p.product_key
    WHERE order_date IS NOT NULL
)
, product_aggregation AS (
/*---------------------------------------------------------------------------
2) Product Aggregations: Summarizing the key metrics at the product level
---------------------------------------------------------------------------*/
SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    DATEDIFF (month, MIN(order_date), MAX(order_date)) AS sales_history,
    MAX (order_date) AS last_sales_date,
    COUNT (DISTINCT order_number) AS total_order,
    COUNT (DISTINCT customer_key) AS total_customers,
    SUM (sales_amount) AS total_sales_amount,
    SUM (quantity) AS total_quantity,
    ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)),1) AS avg_selling_price
FROM base_query
GROUP BY
    product_key,
    product_name,
    category,
    subcategory,
    cost
)
/*---------------------------------------------------------------------------
  3) Final Query: Combines all product results into one output
---------------------------------------------------------------------------*/
SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    sales_history,
    last_sales_date,
    DATEDIFF (month, last_sales_date, GETDATE()) AS recency_in_month,
    total_order,
    total_customers,
    total_sales_amount,
    CASE WHEN total_sales_amount > 50000 THEN 'High-Performer'
         WHEN total_sales_amount >= 10000 THEN 'Mid-Range'
         ELSE 'Low-Performer'
    END AS product_segment,
    total_quantity,
    avg_selling_price,
    -- Average Order Revenue
    CASE WHEN total_order = 0 THEN 0
         ELSE total_sales_amount / total_order
    END AS avg_order_revenue,
    -- Average Monthly Revenue
    CASE WHEN sales_history = 0 THEN total_sales_amount
         ELSE total_sales_amount / sales_history
    END AS avg_monthly_revenue
FROM product_aggregation
