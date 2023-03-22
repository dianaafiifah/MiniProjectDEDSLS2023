-- Anda dibebaskan memilih minimal 3 dari 8 analisis yang bisa dilakukan kemudian uraikan objektif yang ingin dilakukan.
-- Setelah memilih 3 analisis pilihan, silakan uraikan analisis yang ingin dilakukan.
-- Masing-masing analisis minimal 2 uraian dan di dalam query wajib menggunakan salah dua dari beberapa query berikut:
-- Aggregation dan Window Function | Join | Subquery | CTE (with … as …)
-- Filtering (having dan where) | Condition (case when) | String function

USE Northwind;

--1) sales trend analysis
--   to understand how our sales revenue have increased over the year

SELECT 
    LEFT(DATENAME(MONTH, o.OrderDate), 3) AS MonthName,
    SUM(od.UnitPrice * od.Quantity) AS TotalSales
FROM Orders o
INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
WHERE YEAR(o.OrderDate) = 1997
GROUP BY MONTH(o.OrderDate), DATENAME(MONTH, o.OrderDate)
ORDER BY MONTH(o.OrderDate);

--2) top product analysis
--   to understand which products contributed the most to total revenue

SELECT TOP 10
	p.ProductName,
	SUM(od.UnitPrice * od.Quantity) AS TotalSales
FROM Orders o
INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
INNER JOIN Products p ON od.ProductID = p.ProductID
WHERE YEAR(o.OrderDate) IN ('1997', '1996')
GROUP BY p.ProductName
ORDER BY TotalSales DESC;

--3) employee effectiveness analysis
--   to understand how our employee effectiveness differed by country

WITH CTE AS (
    SELECT e.Country, c.CategoryName, SUM(od.Quantity * od.UnitPrice) AS TotalSales
    FROM Orders o
    INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
    INNER JOIN Products p ON od.ProductID = p.ProductID
    INNER JOIN Categories c ON p.CategoryID = c.CategoryID
    INNER JOIN Employees e ON o.EmployeeID = e.EmployeeID
	WHERE YEAR(o.OrderDate) IN ('1997', '1996')
    GROUP BY e.Country, c.CategoryName
)
SELECT 
    Country, 
    SUM(CASE WHEN CategoryName = 'Beverages' THEN TotalSales ELSE 0 END) AS Beverages,
    SUM(CASE WHEN CategoryName = 'Condiments' THEN TotalSales ELSE 0 END) AS Condiments,
    SUM(CASE WHEN CategoryName = 'Confections' THEN TotalSales ELSE 0 END) AS Confections,
	SUM(CASE WHEN CategoryName = 'Dairy Products' THEN TotalSales ELSE 0 END) AS [Dairy Products],
	SUM(CASE WHEN CategoryName = 'Grains/Cereals' THEN TotalSales ELSE 0 END) AS [Grains/Cereals],
    SUM(CASE WHEN CategoryName = 'Meat/Poultry' THEN TotalSales ELSE 0 END) AS [Meat/Poultry],
    SUM(CASE WHEN CategoryName = 'Produce' THEN TotalSales ELSE 0 END) AS Produce,
	SUM(CASE WHEN CategoryName = 'Seafood' THEN TotalSales ELSE 0 END) AS Seafood
FROM CTE
GROUP BY Country;
