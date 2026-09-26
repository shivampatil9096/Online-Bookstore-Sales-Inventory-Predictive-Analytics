<!-- ============================================================
  1. BANNER
  Replace banner.png with a 1280x400px image (Canva/Figma template,
  or just a wide screenshot of your Power BI dashboard's first page).
  Path below assumes it lives in /assets/banner.png in this repo.
============================================================= -->
<p align="center">
  <img src="dashboard_banner.png" alt="Online Bookstore Sales & Inventory Analytics banner" width="100%">
</p>

<h1 align="center"> Online Bookstore Sales & Inventory Predictive Analytics</h1>
<p align="center">
  <b>SQL &nbsp;•&nbsp; Power BI &nbsp;•&nbsp; DAX</b>
</p>

<!-- ============================================================
  2. DESCRIPTION
============================================================= -->
## 📖 Description

This project analyzes sales and inventory data for an online bookstore covering **520 authors**, **10 genres**, **650 titles**, and **1,650+ orders**. It combines SQL for data aggregation with a Power BI dashboard for forecasting and inventory risk monitoring.

**What it does:**
- Aggregates historical sales performance — order velocity, stock levels, and revenue — across authors and genres using SQL.
- Forecasts future demand for top-selling titles and high-performing authors using Power BI's built-in trend/seasonality analytics.
- Surfaces an interactive dashboard with dynamic DAX measures, low-stock alerts, and slicers to support automated stock replenishment decisions.

**Tech stack:** SQL (SQLite/PostgreSQL syntax) · Power BI Desktop · DAX · Excel

---

<!-- ============================================================
  3. LIVE PROJECT LINK
============================================================= -->
## 🔗 Live Project

- 🌐 **Live interactive dashboard:** [View here](https://app.powerbi.com/groups/me/reports/8f8512b3-bbe3-4d73-838c-3c2dd1bd5f79/d7269b45968cb48bc4b6?experience=power-bi)
---

<!-- ============================================================
  4. SCREENSHOTS
============================================================= -->
## 🖼️ Dashboard Screenshots

| Overview | Inventory Risk View |
|---|---|
| ![Dashboard overview]() | ![Inventory risk alerts](screenshots/inventory_alerts.png) |

| Revenue Trend & Forecast | Genre / Author Breakdown |
|---|---|
| ![Forecast chart](screenshots/forecast_trend.png) | ![Genre breakdown](screenshots/genre_breakdown.png) |

---

<!-- ============================================================
  5. SQL CODE — one screenshot + output per query, then a link
============================================================= -->
## 🗄️ SQL Queries & Results

📄 Full script: [`sql/bookstore_queries.sql`](sql/bookstore_queries.sql)

### 1. Revenue by Genre
```sql
SELECT g.genre_name, COUNT(o.order_id) AS total_orders,
       SUM(o.quantity) AS total_units_sold, SUM(o.revenue) AS total_revenue
FROM Orders o
JOIN Books  b ON o.book_id = b.book_id
JOIN Genres g ON b.genre_id = g.genre_id
GROUP BY g.genre_name
ORDER BY total_revenue DESC;
```
![Query 1 result](screenshots/sql/query1_revenue_by_genre.png)

### 2. Top 20 Authors by Revenue
```sql
SELECT a.author_name, SUM(o.revenue) AS total_revenue, SUM(o.quantity) AS units_sold
FROM Orders o
JOIN Books   b ON o.book_id = b.book_id
JOIN Authors a ON b.author_id = a.author_id
GROUP BY a.author_name
ORDER BY total_revenue DESC
LIMIT 20;
```
![Query 2 result](screenshots/sql/query2_top_authors.png)

### 3. Monthly Sales Trend (Seasonality)
```sql
SELECT strftime('%Y-%m', order_date) AS sales_month,
       SUM(quantity) AS units_sold, SUM(revenue) AS monthly_revenue
FROM Orders
GROUP BY sales_month
ORDER BY sales_month;
```
![Query 3 result](screenshots/sql/query3_monthly_trend.png)

### 4. Order Velocity per Book
```sql
SELECT b.title, COUNT(o.order_id) AS num_orders, SUM(o.quantity) AS total_units,
       ROUND(SUM(o.quantity) * 1.0 / COUNT(o.order_id), 2) AS avg_units_per_order
FROM Orders o
JOIN Books b ON o.book_id = b.book_id
GROUP BY b.title
ORDER BY total_units DESC;
```
![Query 4 result](screenshots/sql/query4_order_velocity.png)

### 5. Current Stock Levels by Genre
```sql
SELECT g.genre_name, SUM(b.stock_qty) AS total_stock_on_hand, COUNT(b.book_id) AS num_titles
FROM Books b
JOIN Genres g ON b.genre_id = g.genre_id
GROUP BY g.genre_name
ORDER BY total_stock_on_hand ASC;
```
![Query 5 result](screenshots/sql/query5_stock_by_genre.png)

### 6. Low-Stock / Reorder Alert List
```sql
SELECT b.title, a.author_name, g.genre_name, b.stock_qty, b.reorder_level
FROM Books b
JOIN Authors a ON b.author_id = a.author_id
JOIN Genres  g ON b.genre_id  = g.genre_id
WHERE b.stock_qty <= b.reorder_level
ORDER BY b.stock_qty ASC;
```
![Query 6 result](screenshots/sql/query6_low_stock_alerts.png)

### 7. Top-Selling Titles (Last 90 Days)
```sql
SELECT b.title, SUM(o.quantity) AS units_sold_90d
FROM Orders o
JOIN Books b ON o.book_id = b.book_id
WHERE date(o.order_date) >= date((SELECT MAX(order_date) FROM Orders), '-90 days')
GROUP BY b.title
ORDER BY units_sold_90d DESC
LIMIT 10;
```
![Query 7 result](screenshots/sql/query7_top_sellers_90d.png)

---

<!-- ============================================================
  6. EXCEL / DATASET LINK
============================================================= -->
## 📁 Dataset

📥 **Excel workbook (Genres, Authors, Books, Orders):** [`data/Bookstore_Dataset.xlsx`](data/Bookstore_Dataset.xlsx)

---

## 🚀 How to Run This Yourself

1. Clone the repo: `git clone https://github.com/YOUR-USERNAME/YOUR-REPO-NAME.git`
2. Open `data/Bookstore_Dataset.xlsx` in Excel, or load `sql/bookstore_queries.sql` into any SQL engine (SQLite/PostgreSQL/MySQL).
3. Open `PowerBI/Bookstore_Dashboard.pbix` in Power BI Desktop to explore the live model and DAX measures.

## 🧠 Skills Demonstrated

`SQL Joins & Aggregation` · `Power BI Data Modeling` · `DAX (SUM, DIVIDE, CALCULATE, DATEADD)` · `Forecasting & Seasonality Analysis` · `Dashboard UX (slicers, conditional formatting)` · `Excel`

---

<p align="center"><i>Built as part of a data analytics portfolio project.</i></p>
