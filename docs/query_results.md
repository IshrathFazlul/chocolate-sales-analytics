# Query Results

Sample output of each analytical query, run against the included sample data. Numbers will differ on the full dataset. The SQL is in [`sql/analytics/`](../sql/analytics/).


## Q1 — Revenue by country

| country_name | orders | total_boxes | total_revenue | avg_order_value |
|---|---|---|---|---|
| Australia | 8 | 1018 | 3931.84 | 491.48 |
| Germany | 3 | 375 | 980.61 | 326.87 |
| Japan | 1 | 35 | 583.7 | 583.7 |
| Brazil | 1 | 47 | 527.01 | 527.01 |

## Q2 — Top products by revenue

| product_name | orders | total_boxes | total_revenue |
|---|---|---|---|
| 70% Dark Bar | 4 | 214 | 1850.84 |
| Truffle Gift Box | 2 | 284 | 1500.49 |
| Hazelnut Milk Bar | 2 | 251 | 681.9 |
| Mixed Assortment Box | 1 | 326 | 629.51 |
| Almond Crunch Bar | 1 | 214 | 549.69 |
| 85% Dark Bar | 2 | 154 | 427.07 |
| Milk Classic Bar | 1 | 32 | 383.66 |

## Q3 — Monthly revenue + month-over-month growth % (LAG window)

| year | month | month_name | revenue | mom_growth_pct |
|---|---|---|---|---|
| 2022 | 1 | January | 588.18 |  |
| 2022 | 4 | April | 629.51 | 7.0 |
| 2022 | 5 | May | 383.66 | -39.1 |
| 2022 | 8 | August | 181.16 | -52.8 |
| 2022 | 12 | December | 912.31 | 403.6 |
| 2023 | 2 | February | 910.84 | -0.2 |
| 2023 | 3 | March | 245.91 | -73.0 |
| 2023 | 8 | August | 1076.7 | 337.8 |

## Q4 — Salesperson leaderboard (RANK window)

| salesperson_name | orders | total_revenue | avg_discount_pct | revenue_rank |
|---|---|---|---|---|
| Arjun Mehta | 4 | 1669.41 | 8.2 | 1 |
| Lucas Walker | 3 | 1540.18 | 17.17 | 2 |
| Yuki Sato | 2 | 989.9 | 5.45 | 3 |
| Priya Sharma | 1 | 588.18 | 16.3 | 4 |
| Hannah Müller | 1 | 583.7 | 4.9 | 5 |
| Ananya Gupta | 1 | 470.63 | 12.0 | 6 |
| Rohan Patel | 1 | 181.16 | 13.9 | 7 |

## Q5 — Channel comparison

| channel_name | orders | total_revenue | avg_order_value | avg_discount_pct |
|---|---|---|---|---|
| Retail | 9 | 4096.09 | 455.12 | 9.44 |
| Online | 3 | 1456.44 | 485.48 | 15.1 |
| Wholesale | 1 | 470.63 | 470.63 | 12.0 |

## Q6 — Product share of total revenue (SUM OVER window)

| product_name | revenue | pct_of_total |
|---|---|---|
| 70% Dark Bar | 1850.84 | 30.7 |
| Truffle Gift Box | 1500.49 | 24.9 |
| Hazelnut Milk Bar | 681.9 | 11.3 |
| Mixed Assortment Box | 629.51 | 10.5 |
| Almond Crunch Bar | 549.69 | 9.1 |
| 85% Dark Bar | 427.07 | 7.1 |
| Milk Classic Bar | 383.66 | 6.4 |

## Q7 — Marketing efficiency by country

| country_name | total_revenue | total_marketing | revenue_per_marketing_dollar |
|---|---|---|---|
| Japan | 583.7 | 60.65 | 9.62 |
| Brazil | 527.01 | 76.94 | 6.85 |
| Germany | 980.61 | 223.38 | 4.39 |
| Australia | 3931.84 | 1005.06 | 3.91 |
