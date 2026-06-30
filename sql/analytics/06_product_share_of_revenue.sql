-- Q6. Each product's share of total revenue  [SUM() OVER () window function]
SELECT
    p.product_name,
    ROUND(SUM(f.amount), 2) AS revenue,
    ROUND(100.0 * SUM(f.amount) / SUM(SUM(f.amount)) OVER (), 1) AS pct_of_total
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue DESC;
