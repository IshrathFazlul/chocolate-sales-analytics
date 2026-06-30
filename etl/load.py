"""Extract + clean stage.

Reads the chocolate-sales CSV with pandas, cleans it, and writes a typed
staging table (stg_sales) into SQLite. The SQL build step then turns that into
the star schema.

Cleaning handled here:
  * strip "$" and commas from Amount, then make it numeric
  * coerce the numeric columns
  * parse Order_Date to a real date (YYYY-MM-DD)
  * drop rows with missing keys, bad dates, or non-positive amount / boxes
"""
from __future__ import annotations

import logging

import pandas as pd

logger = logging.getLogger("etl.load")

EXPECTED = [
    "order_id", "product", "country", "channel", "salesperson", "order_date",
    "discount_pct", "price_per_box", "marketing_spend", "boxes_shipped", "amount",
]


def load_staging(conn, csv_path) -> dict:
    df = pd.read_csv(csv_path)
    df.columns = [c.strip().lower() for c in df.columns]
    before = len(df)

    # clean amount: remove "$" and thousands separators, then to number
    df["amount"] = (
        df["amount"].astype(str).str.replace(r"[$,]", "", regex=True)
    )
    for col in ["discount_pct", "price_per_box", "marketing_spend", "amount"]:
        df[col] = pd.to_numeric(df[col], errors="coerce")
    df["boxes_shipped"] = pd.to_numeric(df["boxes_shipped"], errors="coerce")

    # parse dates; bad formats become NaT and are dropped below
    df["order_date"] = pd.to_datetime(df["order_date"], errors="coerce")

    # drop invalid / incomplete rows
    df = df.dropna(subset=EXPECTED)
    df = df[(df["amount"] > 0) & (df["boxes_shipped"] > 0)]
    df["boxes_shipped"] = df["boxes_shipped"].astype(int)
    df["order_date"] = df["order_date"].dt.strftime("%Y-%m-%d")

    removed = before - len(df)
    df[EXPECTED].to_sql("stg_sales", conn, if_exists="replace", index=False)
    conn.commit()

    logger.info("loaded %d clean rows (%d raw, %d dropped)", len(df), before, removed)
    return {"raw": before, "clean": len(df), "dropped": removed}
