-- ============================================================================
-- Build the star schema from the cleaned staging table (stg_sales).
-- stg_sales is loaded by etl/load.py (already typed + cleaned).
-- INSERT OR IGNORE + UNIQUE constraints de-duplicate the dimensions.
-- ============================================================================

-- --- Dimensions -----------------------------------------------------------
INSERT OR IGNORE INTO dim_product (product_name)
SELECT DISTINCT product FROM stg_sales WHERE product IS NOT NULL;

INSERT OR IGNORE INTO dim_country (country_name)
SELECT DISTINCT country FROM stg_sales WHERE country IS NOT NULL;

INSERT OR IGNORE INTO dim_channel (channel_name)
SELECT DISTINCT channel FROM stg_sales WHERE channel IS NOT NULL;

INSERT OR IGNORE INTO dim_salesperson (salesperson_name)
SELECT DISTINCT salesperson FROM stg_sales WHERE salesperson IS NOT NULL;

-- Date dimension: derive the parts from the 'YYYY-MM-DD' text once.
INSERT OR IGNORE INTO dim_date (date_id, full_date, year, quarter, month, month_name, day, day_of_week)
SELECT DISTINCT
    CAST(strftime('%Y%m%d', order_date) AS INTEGER)         AS date_id,
    order_date                                              AS full_date,
    CAST(strftime('%Y', order_date) AS INTEGER)             AS year,
    (CAST(strftime('%m', order_date) AS INTEGER) + 2) / 3   AS quarter,
    CAST(strftime('%m', order_date) AS INTEGER)             AS month,
    CASE CAST(strftime('%m', order_date) AS INTEGER)
        WHEN 1 THEN 'January'  WHEN 2 THEN 'February' WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'    WHEN 5 THEN 'May'      WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'     WHEN 8 THEN 'August'   WHEN 9 THEN 'September'
        WHEN 10 THEN 'October' WHEN 11 THEN 'November' ELSE 'December' END AS month_name,
    CAST(strftime('%d', order_date) AS INTEGER)             AS day,
    CASE strftime('%w', order_date)
        WHEN '0' THEN 'Sunday'    WHEN '1' THEN 'Monday'  WHEN '2' THEN 'Tuesday'
        WHEN '3' THEN 'Wednesday' WHEN '4' THEN 'Thursday' WHEN '5' THEN 'Friday'
        ELSE 'Saturday' END                                AS day_of_week
FROM stg_sales
WHERE order_date IS NOT NULL;

-- --- Fact (with derived columns) ------------------------------------------
DELETE FROM fact_sales;

INSERT INTO fact_sales (
    order_id, product_id, country_id, channel_id, salesperson_id, date_id,
    discount_pct, price_per_box, marketing_spend, boxes_shipped, amount,
    list_amount, discount_value, revenue_after_marketing, avg_price_per_box
)
SELECT
    s.order_id,
    p.product_id,
    c.country_id,
    ch.channel_id,
    sp.salesperson_id,
    CAST(strftime('%Y%m%d', s.order_date) AS INTEGER),
    s.discount_pct,
    s.price_per_box,
    s.marketing_spend,
    s.boxes_shipped,
    s.amount,
    ROUND(s.price_per_box * s.boxes_shipped, 2)                              AS list_amount,
    ROUND(s.price_per_box * s.boxes_shipped * s.discount_pct / 100.0, 2)     AS discount_value,
    ROUND(s.amount - s.marketing_spend, 2)                                   AS revenue_after_marketing,
    ROUND(s.amount / s.boxes_shipped, 2)                                     AS avg_price_per_box
FROM stg_sales s
JOIN dim_product     p  ON s.product     = p.product_name
JOIN dim_country     c  ON s.country     = c.country_name
JOIN dim_channel     ch ON s.channel     = ch.channel_name
JOIN dim_salesperson sp ON s.salesperson = sp.salesperson_name;
