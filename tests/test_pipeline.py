"""Tests: build the model from the sample CSV and check the results.

Data-agnostic, so they pass on the sample or the full dataset.
"""
import sqlite3
import sys
import tempfile
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from etl.db import run_sql_file, scalar        # noqa: E402
from etl.load import load_staging              # noqa: E402

SQL = ROOT / "sql"


@pytest.fixture()
def conn():
    c = sqlite3.connect(":memory:")
    load_staging(c, ROOT / "data" / "chocolate_sales.csv")
    run_sql_file(c, SQL / "01_schema.sql")
    run_sql_file(c, SQL / "02_build_model.sql")
    yield c
    c.close()


def test_staging_loaded(conn):
    assert scalar(conn, "SELECT COUNT(*) FROM stg_sales") > 0


def test_fact_is_non_empty_subset_of_staging(conn):
    stg = scalar(conn, "SELECT COUNT(*) FROM stg_sales")
    fact = scalar(conn, "SELECT COUNT(*) FROM fact_sales")
    assert 0 < fact <= stg


def test_amounts_are_positive(conn):
    assert scalar(conn, "SELECT COUNT(*) FROM fact_sales WHERE amount IS NULL OR amount <= 0") == 0


def test_dimensions_deduplicated(conn):
    dim = scalar(conn, "SELECT COUNT(*) FROM dim_product")
    distinct = scalar(conn, "SELECT COUNT(DISTINCT product) FROM stg_sales")
    assert dim == distinct


def test_derived_column(conn):
    row = conn.execute(
        "SELECT amount, boxes_shipped, avg_price_per_box FROM fact_sales LIMIT 1"
    ).fetchone()
    amount, boxes, avg = row
    assert avg == pytest.approx(round(amount / boxes, 2), abs=0.01)


def test_all_analytics_queries_run(conn):
    for q in sorted((SQL / "analytics").glob("*.sql")):
        conn.execute(q.read_text(encoding="utf-8")).fetchall()  # must not raise


def test_dollar_sign_is_cleaned():
    """A row with amount '$383.66' must load as numeric 383.66."""
    with tempfile.TemporaryDirectory() as d:
        csv = Path(d) / "one.csv"
        csv.write_text(
            "Order_ID,Product,Country,Channel,Salesperson,Order_Date,Discount_Pct,"
            "Price_per_Box,Marketing_Spend,Boxes_Shipped,Amount\n"
            "ORD-1,Bar,Japan,Retail,A,2023-01-01,5,10,50,10,$383.66\n",
            encoding="utf-8",
        )
        c = sqlite3.connect(":memory:")
        load_staging(c, csv)
        val = scalar(c, "SELECT amount FROM stg_sales")
        c.close()
    assert val == pytest.approx(383.66)
