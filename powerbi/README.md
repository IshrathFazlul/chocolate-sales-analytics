# Power BI Dashboard — Build Guide

Builds an interactive chocolate-sales dashboard on the clean data this project
produces. About 20 minutes.

## 1. Get the data
Run `python run.py` in the project root, which writes **`exports/sales_clean.csv`**
(one clean row per order with product, country, channel, salesperson, date,
amount, boxes, discount). A ready-made copy is also in
[`sample_data/`](sample_data/) if you want to start straight away.

## 2. Load it into Power BI
1. **Home → Get data → Text/CSV** → choose `sales_clean.csv` → **Load**.
2. In **Transform data**, confirm types: `order_date` = **Date**,
   `amount` / `discount_pct` / `marketing_spend` = **Decimal number**,
   `boxes_shipped` / `year` / `month` = **Whole number**. **Close & Apply**.

## 3. Add the measures
Add each measure from [`dax_measures.md`](dax_measures.md) (right-click
`sales_clean` → New measure).

## 4. Build the page

```
┌───────────────────────────────────────────────────────────────┐
│  CHOCOLATE SALES DASHBOARD     [Country] [Channel] [Year]      │  slicers
├──────────────┬──────────────┬──────────────┬─────────────────┤
│ Total Revenue│ Total Boxes  │ Order Count  │ Avg Order Value │  KPI cards
├──────────────┴──────────────┴──────────────┴─────────────────┤
│  Revenue by country (bar)   │  Top products by revenue (bar)  │
├─────────────────────────────┼─────────────────────────────────┤
│  Revenue over time (line)   │  Salesperson revenue (table)    │
└─────────────────────────────┴─────────────────────────────────┘
```

- **Slicers:** three Slicer visuals → `country_name`, `channel_name`, `year`.
- **KPI cards:** four Card visuals → `Total Revenue`, `Total Boxes`,
  `Order Count`, `Avg Order Value`.
- **Revenue by country:** Clustered bar → Axis `country_name`, Value `Total Revenue`.
- **Top products:** Clustered bar → Axis `product_name`, Value `Total Revenue`;
  in the Filter pane set a Top-N filter (top 10 by Total Revenue).
- **Revenue over time:** Line chart → Axis `order_date` (use the date, not the
  date hierarchy), Value `Total Revenue`.
- **Salesperson revenue:** Table → `salesperson_name`, `Total Revenue`,
  `Order Count`.

## 5. Polish + save
- Add a title text box "Chocolate Sales Dashboard".
- Optional brand colours: View → Themes → Customize (teal `#2A8B9A`).
- **File → Save As** → `powerbi/chocolate_dashboard.pbix`.
- Screenshot it into `powerbi/screenshots/dashboard.png` for the README.

## Interview line
"I modelled the sales data into a star schema in SQL, wrote the analytical
queries, then built a Power BI dashboard on the clean output with slicers, KPI
cards, and revenue trends — so the SQL feeds an interactive report a manager can
read."
