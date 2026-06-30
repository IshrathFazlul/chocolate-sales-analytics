# Chocolate Sales — SQL Analytics & Power BI Dashboard

An end-to-end analytics project on a chocolate-sales dataset: a Python loader
cleans the raw CSV, **SQL** builds a normalized star schema and answers business
questions, and a **Power BI** dashboard turns the results into an interactive
report.

```
CSV  →  clean (Python)  →  SQLite star schema (SQL)  →  analytics (SQL)  →  Power BI
```

Runs anywhere with Python — no database server to install (uses SQLite, which is
built in).

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

## Run it

```bash
pip install -r requirements.txt
python run.py            # uses data/chocolate_sales.csv (a sample is included)
pytest -q                # tests
```

This creates the SQLite database at `data/chocolate.db`, runs the seven analytical
queries, and writes `exports/sales_clean.csv` for Power BI. To use the full
dataset, drop your CSV in and run `python run.py path/to/your.csv`.

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

## Build the dashboard

The Power BI build guide (with the exact DAX measures and layout) is in
[`powerbi/README.md`](powerbi/README.md). Sample data to import is in
`powerbi/sample_data/`.

## Project layout

```
chocolate-sales-analytics/
├── run.py                     # CSV → SQLite → analytics → Power BI export
├── etl/                       # load.py (clean) + db.py (sqlite helpers)
├── sql/
│   ├── 01_schema.sql          # normalized star schema
│   ├── 02_build_model.sql     # populate dimensions + fact
│   └── analytics/             # 7 business queries
├── powerbi/                   # dashboard build guide + DAX + sample data
├── docs/query_results.md      # the queries with sample output
├── tests/                     # pytest
└── data/chocolate_sales.csv   # sample (replace with the full dataset)
```

## Tech stack
Python · pandas · SQLite · SQL (window functions) · Power BI.
EOF
echo "README written"

cat > requirements.txt << 'EOF'
pandas>=2.0.0
EOF
cat > requirements-dev.txt << 'EOF'
-r requirements.txt
pytest>=8.0.0
EOF
cat > .gitignore << 'EOF'
__pycache__/
*.py[cod]
.venv/
venv/
data/chocolate.db
exports/*.csv
*.log
.pytest_cache/
.DS_Store
EOF
mkdir -p .github/workflows
cat > .github/workflows/ci.yml << 'EOF'
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"
      - run: pip install -r requirements-dev.txt
      - run: python run.py
      - run: pytest -q
EOF
echo "support files written"