/********************************************
 *	UC: Complementos de Bases de Dados 2023/2024
 *
 *	Turma: 2ºL_EI-SW-03 (15:00h - 17:00h)
 *		Nome Aluno: Ricardo Pinto (nº 202200637)
 *		Nome Aluno: Rodrigo Maduro (nº 202200166)
 *	    Nome Aluno: Rodrigo Arraiado (nº 202100436)
 *	
 *			Queries
 ********************************************/


-- Section: QuerySet
USE AdventureWorks;

-- Query: Total monetário de vendas por ano
SELECT
    YEAR(soh.OrderDate) AS Year,
    ROUND(SUM(sod.SalesAmount), 2) AS TotalSales
FROM
    Sales.SalesOrderHeader soh
JOIN
    Sales.SalesOrderDetail sod ON soh.SalesOrderNumber = sod.SalesOrderNumber
GROUP BY
    YEAR(soh.OrderDate)
ORDER BY
    Year;




-- Query: Total monetário de vendas por Categoria de Produto por País do Território de Vendas
SELECT
    st.SalesTerritoryCountry,
    c.EnglishCategoryName AS ProductCategory,
    ROUND(SUM(sod.SalesAmount), 2) AS TotalMonetarySales
FROM
    Sales.SalesOrderHeader soh
JOIN
   Sales.SalesOrderDetail sod ON soh.SalesOrderNumber = sod.SalesOrderNumber
JOIN
    Production.Product p ON sod.ProductKey = p.ProductKey
JOIN
    Production.SubCategory sc ON p.SubCategoryKey = sc.SubCategoryKey
JOIN
    Production.Category c ON sc.CategoryKey = c.CategoryKey
JOIN
    Sales.SalesTerritory st ON soh.SalesTerritoryKey = st.SalesTerritoryKey
GROUP BY
    st.SalesTerritoryCountry, c.EnglishCategoryName
ORDER BY
    st.SalesTerritoryCountry, c.EnglishCategoryName;




-- Query: Número de produtos (vendidos) por Categoria
SELECT
    c.CategoryKey,
    c.FrenchCategoryName,
    c.EnglishCategoryName,
    c.SpanishCategoryName,
    COUNT(p.ProductKey) AS NumberOfProductsSold
FROM
    Production.Category c
JOIN
    Production.SubCategory sc ON c.CategoryKey = sc.CategoryKey
JOIN
    Production.Product p ON sc.SubCategoryKey = p.SubCategoryKey
JOIN
    Sales.SalesOrderDetail sod ON p.ProductKey = sod.ProductKey
GROUP BY
    c.CategoryKey, c.FrenchCategoryName, c.EnglishCategoryName, c.SpanishCategoryName
ORDER BY
    c.CategoryKey;





-- Query: Número de produtos vendidos por SubCategoria por Ano
SELECT
    YEAR(soh.OrderDate) AS SalesYear,
    sc.FrenchSubCategoryName,
    COUNT(sod.ProductKey) AS NumberOfProductsSold
FROM
    Sales.SalesOrderHeader soh
JOIN
    Sales.SalesOrderDetail sod ON soh.SalesOrderNumber = sod.SalesOrderNumber
JOIN
    Production.Product p ON sod.ProductKey = p.ProductKey
JOIN
    Production.SubCategory sc ON p.SubCategoryKey = sc.SubCategoryKey
GROUP BY
    YEAR(soh.OrderDate),
    sc.FrenchSubCategoryName
ORDER BY
    SalesYear, sc.FrenchSubCategoryName;




-- Query: Pesquisa de vendas por cidade
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



-- Query: Taxa de crescimento de vendas por ano e por categoria de produto
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

SELECT * FROM GrowthRate ORDER BY GrowthRate DESC;


-- Query: Número de produtos nas vendas por cor
SELECT
    p.Color,
    COUNT(DISTINCT sod.ProductKey) AS NumberOfProducts
FROM
    Sales.SalesOrderDetail sod
    JOIN Production.Product p ON sod.ProductKey = p.ProductKey
GROUP BY
    p.Color;
