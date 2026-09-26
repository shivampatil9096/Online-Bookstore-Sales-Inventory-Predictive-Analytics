/* ============================================================================
   ONLINE BOOKSTORE — SALES, INVENTORY & PREDICTIVE ANALYTICS
   SIMPLE SQL VERSION — easy to read, explain, and reuse in an interview
   ----------------------------------------------------------------------------
   Data: 1,560 orders | 640 books | 520 authors | 10 genres
   Files: authors.csv, books.csv, orders.csv, inventory.csv
   Works on MySQL / SQL Server / PostgreSQL with no fancy syntax.
   ============================================================================ */


-- ============================================================================
-- SECTION 1: CREATE TABLES (simple, no extra indexes/constraints to worry about)
-- ============================================================================

CREATE TABLE Authors (
    AuthorID   VARCHAR(10),
    AuthorName VARCHAR(100),
    City       VARCHAR(100),
    State      VARCHAR(100),
    DebutYear  INT
);

CREATE TABLE Books (
    BookID      VARCHAR(10),
    Title       VARCHAR(255),
    AuthorID    VARCHAR(10),
    Genre       VARCHAR(60),
    Price_INR   DECIMAL(10,2),
    PublishYear INT,
    Pages       INT
);

CREATE TABLE Orders (
    OrderID       VARCHAR(12),
    OrderDate     DATE,
    BookID        VARCHAR(10),
    Genre         VARCHAR(60),
    QuantitySold  INT,
    UnitPrice_INR DECIMAL(10,2),
    DiscountPct   INT,
    Revenue_INR   DECIMAL(10,2),
    City          VARCHAR(100),
    Channel       VARCHAR(60)
);

CREATE TABLE Inventory (
    BookID          VARCHAR(10),
    CurrentStock    INT,
    ReorderLevel    INT,
    Warehouse       VARCHAR(60),
    LeadTimeDays    INT,
    LastRestockDate DATE
);

-- Import each CSV using your database's Import Wizard (matches column names
-- exactly), or LOAD DATA / BULK INSERT if you prefer command line.


-- ============================================================================
-- SECTION 2: HISTORICAL SALES PERFORMANCE (resume bullet 1)
-- ============================================================================

-- 2.1 How many total order records do we have?
SELECT COUNT(*) AS TotalOrders FROM Orders;

-- 2.2 Revenue by Genre (all 10 genres)
SELECT Genre, SUM(Revenue_INR) AS TotalRevenue, SUM(QuantitySold) AS UnitsSold
FROM Orders
GROUP BY Genre
ORDER BY TotalRevenue DESC;

-- 2.3 Revenue by Author (join Orders -> Books -> Authors)
SELECT a.AuthorName, SUM(o.Revenue_INR) AS TotalRevenue, SUM(o.QuantitySold) AS UnitsSold
FROM Orders o
JOIN Books b ON o.BookID = b.BookID
JOIN Authors a ON b.AuthorID = a.AuthorID
GROUP BY a.AuthorName
ORDER BY TotalRevenue DESC;

-- 2.4 Order velocity: how many units sold per book, per month
SELECT b.Title, MONTH(o.OrderDate) AS OrderMonth, SUM(o.QuantitySold) AS UnitsSold
FROM Orders o
JOIN Books b ON o.BookID = b.BookID
GROUP BY b.Title, MONTH(o.OrderDate)
ORDER BY b.Title, OrderMonth;

-- 2.5 Available stock level for every book (simple lookup)
SELECT b.Title, i.CurrentStock, i.ReorderLevel
FROM Inventory i
JOIN Books b ON i.BookID = b.BookID
ORDER BY i.CurrentStock ASC;

-- 2.6 Total units sold per book (used to calculate velocity/speed of sale)
SELECT b.Title, SUM(o.QuantitySold) AS TotalUnitsSold
FROM Orders o
JOIN Books b ON o.BookID = b.BookID
GROUP BY b.Title
ORDER BY TotalUnitsSold DESC;


-- ============================================================================
-- SECTION 3: FORECASTING SUPPORT — top sellers, top authors, trend by month
-- (resume bullet 2)
-- ============================================================================

-- 3.1 Top 20 best-selling titles
SELECT b.Title, SUM(o.QuantitySold) AS TotalUnitsSold
FROM Orders o
JOIN Books b ON o.BookID = b.BookID
GROUP BY b.Title
ORDER BY TotalUnitsSold DESC
LIMIT 20;                      -- SQL Server: use "SELECT TOP 20" instead of LIMIT

-- 3.2 Top 20 highest revenue authors
SELECT a.AuthorName, SUM(o.Revenue_INR) AS TotalRevenue
FROM Orders o
JOIN Books b ON o.BookID = b.BookID
JOIN Authors a ON b.AuthorID = a.AuthorID
GROUP BY a.AuthorName
ORDER BY TotalRevenue DESC
LIMIT 20;

-- 3.3 Monthly sales trend (for the Power BI trend-line chart)
SELECT YEAR(OrderDate) AS OrderYear, MONTH(OrderDate) AS OrderMonth,
       SUM(Revenue_INR) AS MonthlyRevenue, SUM(QuantitySold) AS MonthlyUnits
FROM Orders
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY OrderYear, OrderMonth;

-- 3.4 Monthly trend broken down by genre (shows seasonality per genre)
SELECT YEAR(o.OrderDate) AS OrderYear, MONTH(o.OrderDate) AS OrderMonth,
       b.Genre, SUM(o.Revenue_INR) AS MonthlyRevenue
FROM Orders o
JOIN Books b ON o.BookID = b.BookID
GROUP BY YEAR(o.OrderDate), MONTH(o.OrderDate), b.Genre
ORDER BY OrderYear, OrderMonth, b.Genre;


-- ============================================================================
-- SECTION 4: INVENTORY RISK ALERTS & REPLENISHMENT (resume bullet 3)
-- ============================================================================

-- 4.1 Simple alert: books at or below their reorder level
SELECT b.Title, i.CurrentStock, i.ReorderLevel
FROM Inventory i
JOIN Books b ON i.BookID = b.BookID
WHERE i.CurrentStock <= i.ReorderLevel
ORDER BY i.CurrentStock ASC;

-- 4.2 Alert with a simple risk label (easy IF/CASE logic)
SELECT
    b.Title,
    i.CurrentStock,
    i.ReorderLevel,
    CASE
        WHEN i.CurrentStock = 0 THEN 'Out of Stock'
        WHEN i.CurrentStock <= i.ReorderLevel THEN 'Low Stock - Reorder'
        ELSE 'Healthy'
    END AS StockStatus
FROM Inventory i
JOIN Books b ON i.BookID = b.BookID;

-- 4.3 Books that are completely out of stock
SELECT b.Title, i.Warehouse
FROM Inventory i
JOIN Books b ON i.BookID = b.BookID
WHERE i.CurrentStock = 0;

-- 4.4 Stock health summary per warehouse (simple GROUP BY + CASE)
SELECT
    Warehouse,
    COUNT(*) AS TotalTitles,
    SUM(CASE WHEN CurrentStock = 0 THEN 1 ELSE 0 END) AS OutOfStockTitles,
    SUM(CASE WHEN CurrentStock <= ReorderLevel AND CurrentStock > 0 THEN 1 ELSE 0 END) AS LowStockTitles
FROM Inventory
GROUP BY Warehouse;

-- 4.5 Revenue and risk together, by genre (one summary table for the dashboard)
SELECT
    b.Genre,
    SUM(o.Revenue_INR) AS TotalRevenue,
    COUNT(DISTINCT b.BookID) AS TitleCount
FROM Books b
LEFT JOIN Orders o ON o.BookID = b.BookID
GROUP BY b.Genre
ORDER BY TotalRevenue DESC;

/* ============================================================================
   END OF FILE — every query here uses only SELECT, JOIN, GROUP BY, WHERE,
   ORDER BY, and simple CASE statements. No window functions, no subqueries,
   no CTEs — easy to explain line by line in an interview.
   ============================================================================ */
