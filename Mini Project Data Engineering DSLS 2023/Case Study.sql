-- Anda dibebaskan memilih minimal 3 dari 8 analisis yang bisa dilakukan kemudian uraikan objektif yang ingin dilakukan.
-- Setelah memilih 3 analisis pilihan, silakan uraikan analisis yang ingin dilakukan. Masing-masing analisis minimal 2 uraian dan di dalam query wajib menggunakan salah dua dari beberapa query berikut:
-- Aggregation dan Window Function | Join | Subquery | CTE (with … as …)
-- Filtering (having dan where) | Condition (case when) | String function

-- Objektif 0: Menganalisis data penjualan dari Northwind database untuk mengidentifikasi tren kunci dan insights, yaitu:
-- 1) produk dengan penjualan tertinggi;
-- 2) kinerja karyawan berdasarkan penjualan tertinggi; dan
-- 3) segmen pelanggan dengan pembelian tertinggi

USE Northwind;

-- Objektif 1: analisis produk dengan penjualan tertinggi
WITH GrandTotalTable AS (
  SELECT SUM(od.UnitPrice * od.Quantity) AS GrandTotalSales,
         SUM(od.Quantity) AS GrandTotalQuantitySold
  FROM [Order Details] od
)
SELECT
	p.ProductName,
	CONVERT(DECIMAL(10, 2),SUM(od.Quantity)) AS TotalQuantitySold,
	CONVERT(DECIMAL(10, 2),SUM(od.Quantity)) / CONVERT(DECIMAL(10,2),GrandTotalQuantitySold) * 100 AS PercentageOfTotalQuantitySold,
	SUM(od.UnitPrice * od.Quantity) AS TotalSales, 
	SUM(od.UnitPrice * od.Quantity) / GrandTotalSales * 100 AS PercentageOfTotalSales
FROM [Order Details] od
INNER JOIN Products p ON od.ProductID = p.ProductID
CROSS JOIN GrandTotalTable gtt
GROUP BY p.ProductName, gtt.GrandTotalQuantitySold, gtt.GrandTotalSales
ORDER BY TotalSales DESC;

-- Objektif 2: analisis kinerja karyawan berdasarkan penjualan tertinggi
WITH EmployeeSalesTable AS (
  SELECT o.EmployeeID, SUM(od.UnitPrice * od.Quantity) AS TotalSales
  FROM Orders o
  JOIN [Order Details] od ON o.OrderID = od.OrderID
  GROUP BY o.EmployeeID
)

SELECT e.FirstName + ' ' + e.LastName AS Name,
	   TotalSales, 
       CASE 
          WHEN TotalSales > (SELECT AVG(TotalSales) FROM EmployeeSalesTable) THEN 'Above Average'
          ELSE 'Below Average'
       END AS SalesPerformance
FROM Employees e
JOIN EmployeeSalesTable est ON e.EmployeeID = est.EmployeeID
ORDER BY TotalSales DESC;

-- Objektif 3: analisis segmen pelanggan dengan pembelian tertinggi
WITH CustomerSales AS (
  SELECT c.Country, c.City, SUM(od.UnitPrice * od.Quantity) as TotalSales
  FROM Orders o
  JOIN [Order Details] od ON o.OrderID = od.OrderID
  JOIN Customers c ON o.CustomerID = c.CustomerID
  GROUP BY c.Country, c.City
)

SELECT Country, City, TotalSales,
       RANK() OVER (PARTITION BY Country ORDER BY TotalSales DESC) as Rank
FROM CustomerSales
WHERE Country IN (
    SELECT Country
    FROM CustomerSales
    GROUP BY Country
    HAVING SUM(TotalSales) > (SELECT AVG(TotalSales) FROM CustomerSales)
)
ORDER BY Country, Rank;
