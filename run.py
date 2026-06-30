"""Run the whole thing: CSV -> SQLite star schema -> analytics -> Power BI exports.

    python run.py                         # uses data/chocolate_sales.csv
    python run.py path/to/your_file.csv   # use a different CSV
"""
import logging
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT))

from etl.db import connect, run_sql_file, scalar          # noqa: E402
from etl.load import load_staging                          # noqa: E402

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)-7s %(message)s",
                    datefmt="%H:%M:%S")
log = logging.getLogger("run")

SQL = ROOT / "sql"
EXPORTS = ROOT / "exports"
PBI_DATA = ROOT / "powerbi" / "sample_data"


def export_for_powerbi(conn):
    """Write a clean flat table + a monthly summary for Power BI to import."""
    import csv
    EXPORTS.mkdir(exist_ok=True)
    PBI_DATA.mkdir(parents=True, exist_ok=True)

    flat_sql = """
        SELECT f.order_id, d.full_date AS order_date, d.year, d.month, d.month_name,
               p.product_name, c.country_name, ch.channel_name, s.salesperson_name,
               f.boxes_shipped, f.discount_pct, f.amount, f.marketing_spend,
               f.revenue_after_marketing, f.avg_price_per_box
        FROM fact_sales f
        JOIN dim_product p     ON f.product_id = p.product_id
        JOIN dim_country c     ON f.country_id = c.country_id
        JOIN dim_channel ch    ON f.channel_id = ch.channel_id
        JOIN dim_salesperson s ON f.salesperson_id = s.salesperson_id
        JOIN dim_date d        ON f.date_id = d.date_id
    """
    for target in (EXPORTS, PBI_DATA):
        cur = conn.execute(flat_sql)
        with open(target / "sales_clean.csv", "w", newline="", encoding="utf-8") as fh:
            w = csv.writer(fh)
            w.writerow([c[0] for c in cur.description])
            w.writerows(cur.fetchall())
    log.info("exported sales_clean.csv for Power BI")


def main(csv_path):
    conn = connect()
    try:
        log.info("1/4 extract + clean")
        load_staging(conn, csv_path)

        log.info("2/4 build star schema")
        run_sql_file(conn, SQL / "01_schema.sql")
        run_sql_file(conn, SQL / "02_build_model.sql")
        for t in ("dim_product", "dim_country", "dim_channel", "dim_salesperson", "dim_date", "fact_sales"):
            log.info("   %-16s %s rows", t, scalar(conn, f"SELECT COUNT(*) FROM {t}"))

        log.info("3/4 run analytics")
        for q in sorted((SQL / "analytics").glob("*.sql")):
            cur = conn.execute(q.read_text(encoding="utf-8"))
            rows = cur.fetchall()
            log.info("   %-32s -> %d rows", q.name, len(rows))

        log.info("4/4 export for Power BI")
        export_for_powerbi(conn)
        log.info("DONE")
    finally:
        conn.close()


if __name__ == "__main__":
    csv = sys.argv[1] if len(sys.argv) > 1 else str(ROOT / "data" / "chocolate_sales.csv")
    main(csv)
