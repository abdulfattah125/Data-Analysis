
### **Q1: Who are the 10 customers with the largest number of orders?**

```sql
SELECT customerid, count(distinct invoiceno) AS number_of_order,
ROUND(SUM(unitprice*quantity)) AS revenue
FROM Online_Retail
WHERE customerid <> ''
GROUP BY customerid
ORDER BY number_of_order DESC
LIMIT 10;
```

---

### **Q2: What are the top products sold for each month?**

```sql
SELECT *
FROM (
    SELECT 
        EXTRACT(Year FROM invoicedate ::date) AS year,
        EXTRACT(month FROM invoicedate ::date) AS month,
        description,
        COUNT(description) AS count_description,
        DENSE_RANK() OVER (
            PARTITION BY EXTRACT(month FROM invoicedate ::date) 
            ORDER BY COUNT(description) DESC
        ) AS rank
    FROM Online_Retail 
    GROUP BY year, month, description
) tab
WHERE rank = 1
ORDER BY year, month;
```

---

### **Q3: What are the top products sold for each country?**

```sql
SELECT *
FROM (
    SELECT 
        country, 
        description, 
        COUNT(description) AS count_description, 
        DENSE_RANK() OVER (
            PARTITION BY country  
            ORDER BY COUNT(description) DESC
        ) AS rank
    FROM Online_Retail 
    GROUP BY country, description  
    HAVING COUNT(description) > 10
) tab
WHERE rank = 1;
```

---

### **Q4: What is the monthly revenue growth rate?**

```sql
WITH revenue_monthly AS (
    SELECT EXTRACT(Year FROM invoicedate ::date) AS year,
           EXTRACT(month FROM invoicedate ::date) AS month,
           SUM(unitprice * Quantity) AS revenue
    FROM Online_Retail
    WHERE Quantity > 0
    GROUP BY year, month
    ORDER BY year, month
),
revenue_previous_month AS (
    SELECT year, month, revenue,
           LAG(revenue) OVER (ORDER BY year, month) AS previous_revenue
    FROM revenue_monthly
)
SELECT year, month, ROUND(revenue) AS revenue,
       ROUND(previous_revenue) AS previous_revenue,
       CASE
           WHEN previous_revenue IS NULL THEN 0
           ELSE ROUND(CAST((revenue - previous_revenue) / previous_revenue * 100 AS numeric), 2)
       END AS revenue_growth_rate
FROM revenue_previous_month
ORDER BY year, month;
```

---

### **Q5: What is the monthly order rate contribution from the total orders?**

```sql
WITH orders_monthly AS (
    SELECT EXTRACT(Year FROM invoicedate ::date) AS year,
           EXTRACT(month FROM invoicedate ::date) AS month,
           COUNT(DISTINCT InvoiceNo) AS num_of_order,
           SUM(COUNT(DISTINCT InvoiceNo)) OVER() AS total_order
    FROM Online_Retail
    GROUP BY year, month
    ORDER BY year, month
)
SELECT year, month, num_of_order, total_order,
       ROUND((num_of_order / total_order) * 100, 2) AS percent_FROM_total
FROM orders_monthly;
```

---

### **Q6: What is the sales growth rate for each month compared to the previous month (for products priced ≤ 10)?**

```sql
WITH monthly_sales AS (
    SELECT EXTRACT(Year FROM invoicedate ::date) AS year,
           EXTRACT(month FROM invoicedate ::date) AS month, 
           ROUND(SUM(quantity * unitprice) :: numeric, 2) AS total_sales
    FROM Online_Retail
    WHERE unitprice <= 10
    GROUP BY year, month
)
SELECT year, month, total_sales,
       LAG(total_sales) OVER (ORDER BY year, month) AS prev_month_sales,
       ROUND(((total_sales - LAG(total_sales) OVER (ORDER BY year, month)) / LAG(total_sales) OVER (ORDER BY year, month) * 100) :: numeric, 2) || '%' AS growth_rate
FROM monthly_sales 
ORDER BY year, month;
```

---

### **Q7: How many customers, orders, and items were sold for each country?**

```sql
SELECT country,
       COUNT(DISTINCT customerid) AS customers_country,
       SUM(COUNT(DISTINCT customerid)) OVER() AS over_all_customers,
       COUNT(DISTINCT invoiceno) AS orders_country,
       SUM(COUNT(DISTINCT invoiceno)) OVER() AS over_all_orders,
       COUNT(description) AS items_country,
       SUM(COUNT(description)) OVER() AS over_all_items,
       DENSE_RANK() OVER (ORDER BY COUNT(DISTINCT customerid) DESC, COUNT(DISTINCT invoiceno) DESC, COUNT(description) DESC) AS rank
FROM Online_Retail
GROUP BY country
ORDER BY customers_country DESC;
```

---

### **Q8: How many customers, orders, and items were sold each month in the United Kingdom?**

```sql
SELECT EXTRACT(Year FROM invoicedate ::date) AS year,
       EXTRACT(month FROM invoicedate ::date) AS month,
       COUNT(DISTINCT customerid) AS total_customers,
       SUM(COUNT(DISTINCT customerid)) OVER() AS over_all_customers_VistingOverYear,
       COUNT(DISTINCT invoiceno) AS total_orders,
       SUM(COUNT(DISTINCT invoiceno)) OVER() AS over_all_orders_overYear,
       COUNT(description) AS total_items,
       SUM(COUNT(description)) OVER() AS over_all_items_overYear,
       DENSE_RANK() OVER (ORDER BY COUNT(DISTINCT customerid) DESC, COUNT(DISTINCT invoiceno) DESC, COUNT(description) DESC) AS rank
FROM Online_Retail
WHERE country = 'United Kingdom'
GROUP BY EXTRACT(Year FROM invoicedate ::date), EXTRACT(month FROM invoicedate ::date)
ORDER BY year, month;
```

---

### **Q9: How do customers rank based on total spending, and how does it compare to their immediate neighbors?**

```sql
WITH customer_spending AS (
    SELECT CustomerID,
           ROUND(SUM(Quantity * UnitPrice) :: numeric, 2) AS total_spending
    FROM Online_Retail
    GROUP BY CustomerID 
    HAVING COUNT(description) > 10
)
SELECT CustomerID, total_spending,
       RANK() OVER (ORDER BY total_spending DESC) AS spending_rank,
       LAG(total_spending) OVER (ORDER BY total_spending DESC) AS prev_spending,
       LEAD(total_spending) OVER (ORDER BY total_spending DESC) AS next_spending
FROM customer_spending;
```

---

### **Q10: What is the percentage of orders for each month relative to the total orders for the year?**

```sql
WITH orders_monthly AS (
    SELECT EXTRACT(Year FROM invoicedate ::date) AS year,
           EXTRACT(month FROM invoicedate ::date) AS month,
           COUNT(DISTINCT InvoiceNo) AS num_of_order
    FROM Online_Retail 
    GROUP BY year, month
    ORDER BY year, month
),
orders_yearly AS (
    SELECT year,
           SUM(num_of_order) AS total_order_year
    FROM orders_monthly
    GROUP BY year
)
SELECT om.year, om.month, om.num_of_order, oy.total_order_year,
       ROUND(((om.num_of_order / oy.total_order_year) * 100) :: numeric, 2) || '%' AS percentage
FROM orders_monthly om
JOIN orders_yearly oy ON om.year = oy.year
ORDER BY om.year, om.month;
```

---
