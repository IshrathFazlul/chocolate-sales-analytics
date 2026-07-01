# Chocolate Sales — SQL Analytics & Power BI Dashboard

An end-to-end analytics project on a chocolate-sales dataset: a Python loader
cleans the raw CSV, **SQL** builds a normalized star schema and answers business
questions, and a **Power BI** dashboard turns the results into an interactive
report.

```
CSV  →  clean (Python)  →  SQLite star schema (SQL)  →  analytics (SQL)  →  Power BI
```


## Highlights

- **SQL data modelling** — a normalized star schema (5 dimensions + a fact
  table) with surrogate keys and derived columns: [`sql/01_schema.sql`](sql/01_schema.sql), [`sql/02_build_model.sql`](sql/02_build_model.sql).
- **Analytical SQL** — seven business queries using joins, aggregation, `HAVING`,
  and **window functions** (`RANK`, `LAG` for growth %, `SUM() OVER ()` for
  share of total): [`sql/analytics/`](sql/analytics/). Sample results in
  [`docs/query_results.md`](docs/query_results.md).
- **Data cleaning** — handles real dirt: strips `$` from amounts, parses dates,
  and drops invalid rows (a 200k-row test load cleaned and kept 197,343 rows,
  dropping 2,657 bad ones).
- **Power BI dashboard** — slicers, KPI cards, and revenue trends built on the
  clean output: [`powerbi/`](powerbi/README.md).


## The data model

A normalized star schema. Repeating labels (product, country, channel,
salesperson, date) live once in dimension tables; `fact_sales` references them by
key and stores the measures plus derived columns (`list_amount`,
`discount_value`, `revenue_after_marketing`, `avg_price_per_box`).

```
dim_product ─┐
dim_country ─┤
dim_channel ─┼─<  fact_sales  (one row per order line)
dim_salesperson ─┤
dim_date ────┘
```

## The questions the SQL answers

Revenue by country · top products · monthly revenue with month-over-month growth
· salesperson leaderboard · channel comparison · each product's share of revenue
· marketing efficiency by country.

## Project layout

```
chocolate-sales-analytics/
├── run.py                     # CSV → SQLite → analytics → Power BI export
├── etl/                       # load.py (clean) + db.py (sqlite helpers)
├── sql/
│   ├── 01_schema.sql          # normalized star schema
│   ├── 02_build_model.sql     # populate dimensions + fact
│   └── analytics/             # 7 business queries
├── powerbi/                   # dashboard build guide + DAX + data
├── docs/query_results.md      # the queries with sample output
├── tests/                     # pytest
└── data/chocolate_sales.csv   # dataset
```
