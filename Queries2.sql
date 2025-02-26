
/********************************************
 *	UC: Complementos de Bases de Dados 2023/2024
 *
 *	Turma: 2ºL_EI-SW-03 (15:00h - 17:00h)
 *		Nome Aluno: Ricardo Pinto (nº 202200637)
 *		Nome Aluno: Rodrigo Maduro (nº 202200166)
 *	    Nome Aluno: Rodrigo Arraiado (nº 202100436)
 *	
 *			Views for Indexes
 ********************************************/

 use AdventureWorks;
go

DROP VIEW IF EXISTS Sales.SalesByCityView;
GO
DROP VIEW IF EXISTS Sales.SalesGrowthRateView;
GO
DROP VIEW IF EXISTS Production.ProductsByColorView;
GO

-- View: Pesquisa de vendas por cidade
CREATE VIEW Sales.SalesByCityView AS
SELECT
    a.City AS CityName,
    a.StateProvince AS StateCode,
    SUM(sod.SalesAmount) AS TotalSales
FROM
    Sales.SalesOrderDetail sod
    JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderNumber = soh.SalesOrderNumber
    JOIN Sales.Address a ON soh.CustomerKey = a.CustomerKey
GROUP BY
    a.City, a.StateProvince;



GO
-- View: Taxa de crescimento de vendas por ano e por categoria de produto
CREATE VIEW Sales.SalesGrowthRateView AS
WITH SalesByYear AS (
    SELECT
        YEAR(soh.OrderDate) AS SalesYear,
        p.SubCategoryKey,
        SUM(sod.SalesAmount) AS TotalSales
    FROM
        Sales.SalesOrderDetail sod
        JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderNumber = soh.SalesOrderNumber
        JOIN Production.Product p ON sod.ProductKey = p.ProductKey
    GROUP BY
        YEAR(soh.OrderDate), p.SubCategoryKey
),

GrowthRate AS (
    SELECT
        s1.SalesYear,
        c.EnglishCategoryName AS ProductCategory,
        (s1.TotalSales - LAG(s1.TotalSales, 1, 0) OVER (PARTITION BY s1.SubCategoryKey ORDER BY s1.SalesYear)) / LAG(s1.TotalSales, 1, 1) OVER (PARTITION BY s1.SubCategoryKey ORDER BY s1.SalesYear) AS GrowthRate
    FROM
        SalesByYear s1
        JOIN Production.Category c ON s1.SubCategoryKey = c.CategoryKey
)

SELECT SalesYear, ProductCategory, GrowthRate
FROM GrowthRate;

GO

GO
-- View: Número de produtos nas vendas por cor
CREATE VIEW Production.ProductsByColorView AS
SELECT
    p.Color,
    COUNT(DISTINCT sod.ProductKey) AS NumberOfProducts
FROM
    Sales.SalesOrderDetail sod
    JOIN Production.Product p ON sod.ProductKey = p.ProductKey
GROUP BY
    p.Color;

GO


-- Correr as views
SELECT * FROM Sales.SalesByCityView;
GO
SELECT * FROM Sales.SalesGrowthRateView;
GO
SELECT * FROM Production.ProductsByColorView;