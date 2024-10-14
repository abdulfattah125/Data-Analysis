### **RFM Segmentation Query**

segments customers into different groups based on their **Recency**, **Frequency**, and **Monetary** values. The segmentation labels customers as 'Champions', 'Potential Loyalists', 'Loyal Customers', etc., based on their purchasing behavior.

```sql
WITH fundamental AS (
    SELECT 
        customerid,
        (SELECT MAX(invoicedate::date) FROM Online_Retail) - MAX(invoicedate::date) AS recency,
        CAST(COUNT(DISTINCT invoiceno) AS NUMERIC) AS frequency,
        ROUND(CAST(SUM(unitprice * Quantity) AS NUMERIC), 2) AS monetary
    FROM Online_Retail
    WHERE customerid <> ' ' AND Quantity > 0
    GROUP BY customerid
),
r_scored AS (
    SELECT 
        customerid, recency, frequency, monetary,
        ROUND((frequency + monetary) / 2 ::numeric, 2 ) AS fm_avg,
        CASE
            WHEN recency BETWEEN 0 AND MAX(recency) OVER () / 5 THEN 5
            WHEN recency BETWEEN MAX(recency) OVER () / 5 + 1 AND MAX(recency) OVER () / 5 * 2 THEN 4
            WHEN recency BETWEEN MAX(recency) OVER () / 5 * 2 + 1 AND MAX(recency) OVER () / 5 * 3 THEN 3
            WHEN recency BETWEEN MAX(recency) OVER () / 5 * 3 + 1 AND MAX(recency) OVER () / 5 * 4 THEN 2
            WHEN recency BETWEEN MAX(recency) OVER () / 5 * 4 + 1 AND MAX(recency) OVER () / 5 * 5 THEN 1
            ELSE 0
        END AS R_Score
    FROM fundamental
),
fm_scored AS (
    SELECT 
        customerid, recency, frequency, monetary, R_Score, fm_avg,
        CASE
            WHEN fm_avg BETWEEN MIN(fm_avg) AND MAX(fm_avg) OVER () / 5 THEN 1
            WHEN fm_avg BETWEEN MAX(fm_avg) OVER () / 5 + 1 AND MAX(fm_avg) OVER () / 5 * 2 THEN 2
            WHEN fm_avg BETWEEN MAX(fm_avg) OVER () / 5 * 2 + 1 AND MAX(fm_avg) OVER () / 5 * 3 THEN 3
            WHEN fm_avg BETWEEN MAX(fm_avg) OVER () / 5 * 3 + 1 AND MAX(fm_avg) OVER () / 5 * 4 THEN 4
            ELSE 5
        END AS F_M_Score
    FROM r_scored
    GROUP BY customerid, recency, frequency, monetary, R_Score, fm_avg
)
SELECT 
    customerid, recency, frequency, monetary, R_Score, F_M_Score,
    CASE
        WHEN R_Score = 5 AND F_M_Score IN (5, 4) THEN 'Champions'
        WHEN R_Score = 4 AND F_M_Score = 5 THEN 'Champions'
        WHEN R_Score IN (5, 4) AND F_M_Score = 2 THEN 'Potential Loyalists'
        WHEN R_Score IN (3, 4) AND F_M_Score = 3 THEN 'Potential Loyalists'
        WHEN R_Score = 5 AND F_M_Score = 3 THEN 'Loyal Customers'
        WHEN R_Score = 4 AND F_M_Score = 4 THEN 'Loyal Customers'
        WHEN R_Score = 3 AND F_M_Score IN (5, 4) THEN 'Loyal Customers'
        WHEN R_Score = 5 AND F_M_Score = 1 THEN 'Recent Customers'
        WHEN R_Score = 4 AND F_M_Score = 1 THEN 'Promising'
        WHEN R_Score = 3 AND F_M_Score = 1 THEN 'Promising'
        WHEN R_Score = 2 AND F_M_Score IN (2, 3) THEN 'Customers Needing Attention'
        WHEN R_Score = 3 AND F_M_Score = 2 THEN 'Customers Needing Attention'
        WHEN R_Score = 2 AND F_M_Score IN (4, 5) THEN 'At Risk'
        WHEN R_Score = 1 AND F_M_Score = 3 THEN 'At Risk'
        WHEN R_Score = 1 AND F_M_Score IN (4, 5) THEN 'Can’t Lose Them'
        WHEN R_Score = 1 AND F_M_Score = 2 THEN 'Hibernating'
        WHEN R_Score = 1 AND F_M_Score = 1 THEN 'Lost'
        ELSE 'Undefined'
    END AS Customer_Segment
FROM fm_scored
ORDER BY F_M_Score DESC;
```

### **Explanation:**
- **Recency**: The number of days since the customer made their last purchase.
- **Frequency**: The number of distinct orders made by the customer.
- **Monetary**: The total monetary value of a customer’s purchases.
- **R_Score**: A score based on how recent the last purchase was (scored from 1 to 5).
- **F_M_Score**: A score based on the average of frequency and monetary value (scored from 1 to 5).
- **Customer_Segment**: The final customer segmentation based on the combination of `R_Score` and `F_M_Score`. Segments include:
  - **Champions**: Recently purchased, frequent, and high spenders.
  - **Loyal Customers**: Frequent shoppers with good spending habits.
  - **At Risk**: Haven't purchased in a while, but previously had good spending.
  - **Lost**: Haven’t purchased in a long time and with low spending history.

