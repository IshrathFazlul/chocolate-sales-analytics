# DAX Measures

Create these on the `sales_clean` table (right-click the table → **New measure**,
paste, Enter). They're simple aggregations — much less fiddly than time-based
measures.

```DAX
Total Revenue = SUM ( sales_clean[amount] )
```
```DAX
Total Boxes = SUM ( sales_clean[boxes_shipped] )
```
```DAX
Order Count = COUNTROWS ( sales_clean )
```
```DAX
Avg Order Value = AVERAGE ( sales_clean[amount] )
```
```DAX
Avg Discount % = AVERAGE ( sales_clean[discount_pct] )
```
Format **Avg Discount %** as a percentage *only if* you first divide by 100
(the column is stored as a number like `12.5`, meaning 12.5%). Simplest: leave it
as a plain number labelled "Avg Discount (%)".

Tip: if a measure won't save, retype it by hand rather than pasting — that avoids
hidden characters from copied text.
