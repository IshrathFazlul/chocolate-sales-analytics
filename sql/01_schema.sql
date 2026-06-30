-- ============================================================================
-- Chocolate Sales - normalized SQLite schema (star schema)
--
-- Repeating text values (product, country, channel, salesperson, date) are
-- pulled out of the flat data into dimension tables with surrogate keys, and
-- fact_sales references them by foreign key. This removes redundancy and keeps
-- the analytical queries clean.
-- ============================================================================

DROP TABLE IF EXISTS fact_sales;
DROP TABLE IF EXISTS dim_product;
DROP TABLE IF EXISTS dim_country;
DROP TABLE IF EXISTS dim_channel;
DROP TABLE IF EXISTS dim_salesperson;
DROP TABLE IF EXISTS dim_date;

CREATE TABLE dim_product (
    product_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    product_name TEXT NOT NULL UNIQUE
);

CREATE TABLE dim_country (
    country_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    country_name TEXT NOT NULL UNIQUE
);

CREATE TABLE dim_channel (
    channel_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    channel_name TEXT NOT NULL UNIQUE
);

CREATE TABLE dim_salesperson (
    salesperson_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    salesperson_name TEXT NOT NULL UNIQUE
);

CREATE TABLE dim_date (
    date_id     INTEGER PRIMARY KEY,   -- yyyymmdd
    full_date   TEXT NOT NULL UNIQUE,  -- 'YYYY-MM-DD'
    year        INTEGER NOT NULL,
    quarter     INTEGER NOT NULL,
    month       INTEGER NOT NULL,
    month_name  TEXT NOT NULL,
    day         INTEGER NOT NULL,
    day_of_week TEXT NOT NULL
);

CREATE TABLE fact_sales (
    sales_id        INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id        TEXT NOT NULL,
    product_id      INTEGER NOT NULL REFERENCES dim_product(product_id),
    country_id      INTEGER NOT NULL REFERENCES dim_country(country_id),
    channel_id      INTEGER NOT NULL REFERENCES dim_channel(channel_id),
    salesperson_id  INTEGER NOT NULL REFERENCES dim_salesperson(salesperson_id),
    date_id         INTEGER NOT NULL REFERENCES dim_date(date_id),
    discount_pct    REAL,
    price_per_box   REAL,
    marketing_spend REAL,
    boxes_shipped   INTEGER,
    amount          REAL,
    -- derived columns (computed in SQL)
    list_amount             REAL,   -- price_per_box * boxes_shipped
    discount_value          REAL,   -- list_amount * discount_pct / 100
    revenue_after_marketing REAL,   -- amount - marketing_spend
    avg_price_per_box       REAL    -- amount / boxes_shipped
);

CREATE INDEX idx_fact_date    ON fact_sales(date_id);
CREATE INDEX idx_fact_country ON fact_sales(country_id);
CREATE INDEX idx_fact_product ON fact_sales(product_id);
